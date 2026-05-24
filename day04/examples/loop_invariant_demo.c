/* Day 4 — bounded loop verification, and why "for all n" needs induction.
 *
 * The loop increments x once per iteration, so the loop invariant — the
 * inductive fact "after i iterations, x == i" — gives x == n on exit. CBMC is a
 * BOUNDED model checker: it can confirm this for every n UP TO a bound, but not
 * for all n at once. So we:
 *   1. bound the loop count with __CPROVER_assume(n <= N), then
 *   2. unwind N+1 times with --unwinding-assertions (which also PROVES the loop
 *      never runs longer than that bound).
 *
 * Verify:
 *      cbmc loop_invariant_demo.c --unwind 21 --unwinding-assertions
 * Expected:  VERIFICATION SUCCESSFUL  (covers every n in 0..20)
 *
 * The bridge to Day 3: here we had to PICK a bound N and could only prove the
 * property for n <= N. The Lean proof (Counter.lean) discharges the analogous
 * fact for ALL n at once, by induction on the step relation — no bound, using
 * exactly this kind of invariant. Bounded checking refutes cheaply; induction
 * proves universally.
 *
 * Starter: loop_invariant_demo_starter.c
 */
#include <assert.h>          /* assert(): each becomes a CBMC proof goal */

#define N 20                 /* the loop bound we verify up to */

/* nondet_*: no body on purpose — CBMC treats it as a free, unconstrained value. */
unsigned nondet_uint(void);

int main(void)
{
    unsigned n = nondet_uint();
    __CPROVER_assume(n <= N);         /* bound the loop so BMC can cover every case */

    unsigned x = 0;
    unsigned i = 0;
    while (i < n) {                   /* loop invariant (inductive fact): x == i */
        x += 1;
        i += 1;
    }

    assert(x == n);   /* holds for every n in 0..N; the invariant x==i is why */
    return 0;
}
