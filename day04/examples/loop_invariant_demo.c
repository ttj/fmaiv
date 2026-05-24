/* Day 4 — CBMC loop invariants: proving a loop for ALL n, not just up to a bound.
 *
 * The other CBMC examples bound the loop and UNWIND it (--unwind K), which only
 * checks executions shorter than K. A LOOP INVARIANT lets CBMC prove a property
 * for EVERY iteration count at once — the same inductive idea as Day 3, now in C.
 *
 * The loop increments x once per iteration. The invariant `x == i` is the
 * inductive fact "after i iterations, x equals i". CBMC checks it is
 *   (a) true on entry,            (b) preserved by the body, and
 *   (c) strong enough on exit to prove the post-condition  x == n
 * with NO unwinding bound on n.
 *
 * Verify (note: NO --unwind needed — the invariant replaces the loop):
 *      cbmc loop_invariant_demo.c --apply-loop-contracts
 * Expected:  VERIFICATION SUCCESSFUL
 *
 * Contrast: without the invariant you would need --unwind n+1 for each concrete
 * n, and could never cover all n at once. The loop invariant is to CBMC what the
 * inductive invariant (counterInv in Counter.lean) is to the Lean proof.
 *
 * Starter: loop_invariant_demo_starter.c
 */
#include <assert.h>          /* assert(): each becomes a CBMC proof goal */

/* nondet_*: no body on purpose — CBMC treats it as a free, unconstrained value. */
unsigned nondet_uint(void);

int main(void)
{
    unsigned n = nondet_uint();      /* an ARBITRARY iteration count (any unsigned) */
    unsigned x = 0;
    unsigned i = 0;

    while (i < n)
    __CPROVER_loop_invariant(i <= n)          /* i never overshoots n */
    __CPROVER_loop_invariant(x == i)          /* the inductive fact: x tracks i */
    {
        x += 1;
        i += 1;
    }

    assert(x == n);   /* PROVED for every n at once, with no unwinding bound */
    return 0;
}
