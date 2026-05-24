/* Day 4 — bounded loop verification — STARTER (add the one missing line).
 *
 * Goal: prove `assert(x == n)` with CBMC. The loop invariant "x == i" makes it
 * true, but CBMC is a BOUNDED checker — it unwinds the loop a fixed number of
 * times. Run it as given:
 *
 *      cbmc loop_invariant_demo_starter.c --unwind 21 --unwinding-assertions
 *
 * It reports an UNWINDING ASSERTION failure: `n` is unbounded, so the loop can
 * run more than 21 times and CBMC cannot cover every case.
 *
 * Your task: bound the loop with  __CPROVER_assume(n <= N);  right after reading
 * n. Then it reports VERIFICATION SUCCESSFUL (every n in 0..N is covered).
 *
 * Lesson: bounded model checking needs you to bound the loop; proving the
 * property for ALL n (no bound) is what Day-3 induction is for.
 * Worked solution: loop_invariant_demo.c
 */
#include <assert.h>

#define N 20

unsigned nondet_uint(void);

int main(void)
{
    unsigned n = nondet_uint();
    /* TODO: bound the loop so bounded model checking can cover every case:
           __CPROVER_assume(n <= N);
       Without it, --unwinding-assertions fails (n can exceed the unwind depth). */

    unsigned x = 0;
    unsigned i = 0;
    while (i < n) {                   /* loop invariant (inductive fact): x == i */
        x += 1;
        i += 1;
    }

    assert(x == n);
    return 0;
}
