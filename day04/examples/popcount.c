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

#include <stdint.h>          /* gives the fixed-width type uint8_t = an 8-bit unsigned byte */

/* Reference: textbook loop. Counts 1-bits by inspecting each bit position. */
uint8_t popcount_loop(uint8_t x)
{
    uint8_t count = 0;
    for (int i = 0; i < 8; ++i) {       /* visit each of the 8 bit positions */
        /* (x >> i) shifts bit i down to the lowest position; `& 1U` keeps only
         * that one bit (0 or 1). Adding it tallies whether bit i was set. */
        count += (x >> i) & 1U;
    }
    return count;
}

/* Kernighan's trick: clear the lowest set bit each pass; count the passes. */
uint8_t popcount_kernighan(uint8_t x)
{
    uint8_t count = 0;
    while (x != 0) {                     /* keep going until no 1-bits remain */
        /* x & (x-1) erases exactly the lowest set bit of x (a classic identity). */
        x &= (uint8_t)(x - 1U);
        count++;                         /* one more 1-bit accounted for */
    }
    return count;
}

/* GCC builtin, for comparison. Uses the compiler's own popcount. */
uint8_t popcount_builtin(uint8_t x)
{
    return (uint8_t)__builtin_popcount(x);   /* cast int result back to a byte */
}
