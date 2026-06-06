/*
 * Phase 2 toolchain smoke test.
 * Thin bare-metal C: no CRT0, no DIFs, tohost pass/fail convention.
 * Startup is handled by the TEST ROM at runtime; this file is the payload only.
 *
 * Pass: write 1 to tohost
 * Fail: write 0 to tohost (or loop forever)
 */

/* tohost is read by the simulation host to determine pass/fail */
volatile int tohost = 0;

int main(void) {
    /* Exercise: read a compile-time constant to prevent dead-code elimination */
    volatile unsigned int x = 0xDEADBEEFu;
    (void)x;

    tohost = 1; /* PASS */
    return 0;
}
