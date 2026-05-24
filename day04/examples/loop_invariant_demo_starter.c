/* Day 4 — CBMC loop invariants — STARTER (add the one missing invariant).
 *
 * Goal: prove `assert(x == n)` for EVERY n at once, with no unwinding bound,
 * using a loop invariant instead of --unwind. This is the C-level version of
 * the Day-3 inductive invariant.
 *
 * Run:
 *      cbmc loop_invariant_demo_starter.c --apply-loop-contracts
 * As given it reports VERIFICATION FAILED: CBMC knows i == n when the loop ends,
 * but nothing relates x to i, so it cannot conclude x == n.
 *
 * Your task: add the invariant that links x to the iteration count i. Then it
 * reports VERIFICATION SUCCESSFUL. Worked solution: loop_invariant_demo.c
 */
#include <assert.h>

unsigned nondet_uint(void);

int main(void)
{
    unsigned n = nondet_uint();
    unsigned x = 0;
    unsigned i = 0;

    while (i < n)
    __CPROVER_loop_invariant(i <= n)          /* given: i never overshoots n */
    /* TODO: add a second loop invariant linking x to i. After i iterations x has
       been incremented i times, so the inductive fact is:
            __CPROVER_loop_invariant(x == i)
       Without it the post-condition x == n is not provable. */
    {
        x += 1;
        i += 1;
    }

    assert(x == n);
    return 0;
}
