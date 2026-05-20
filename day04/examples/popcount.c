/* Day 4 — popcount in C, three implementations.
 *
 * Companion to popcount.cry. We can verify each of these against the
 * Cryptol specification via the Software Analysis Workbench (SAW),
 * which extracts a symbolic model of the C function with LLVM bitcode
 * and proves equivalence against the Cryptol model with Z3/SBV.
 *
 * Build (for SAW):
 *      clang -c -emit-llvm -O0 -o popcount.bc popcount.c
 *
 * Verify with SAW (run `saw popcount.saw` after writing the .saw script
 * — see the assignment text for a template):
 *      saw popcount.saw
 *
 * Verify with CBMC (independent check; matches a textbook reference):
 *      cbmc popcount.c --function popcount_loop --unwinding-assertions
 */

#include <stdint.h>

/* Reference: textbook loop. */
uint8_t popcount_loop(uint8_t x)
{
    uint8_t count = 0;
    for (int i = 0; i < 8; ++i) {
        count += (x >> i) & 1U;
    }
    return count;
}

/* Kernighan's trick. */
uint8_t popcount_kernighan(uint8_t x)
{
    uint8_t count = 0;
    while (x != 0) {
        x &= (uint8_t)(x - 1U);
        count++;
    }
    return count;
}

/* GCC builtin, for comparison. */
uint8_t popcount_builtin(uint8_t x)
{
    return (uint8_t)__builtin_popcount(x);
}
