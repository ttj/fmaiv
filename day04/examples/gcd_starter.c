/* STARTER -- finish the harness so cbmc proves gcd(a, b) divides both
 * a and b for the bounded input range below.
 *
 * Steps to fill in (search "TODO"):
 *   1.  Constrain (a, b) to [0..20] x [0..20] using __CPROVER_assume.
 *   2.  Call gcd; bind the result to g.
 *   3.  Assert the divisibility spec, with the (0, 0) edge case handled.
 *
 * Verify with:
 *   cbmc gcd.c gcd_starter.c --unwind 11 --unwinding-assertions
 *   -> VERIFICATION SUCCESSFUL  (when complete)
 *
 * For the TEST-GENERATION angle, swap the property mode for:
 *   cbmc gcd.c gcd_starter.c --cover branch --unwind 11
 *   -> one SATISFIED goal per branch in gcd(), each with a concrete
 *      (a, b) witness you could turn into a unit test.
 */
#include <assert.h>

int gcd(int a, int b);

int nondet_int(void);

int main(void)
{
    int a = nondet_int();
    int b = nondet_int();

    /* TODO 1: constrain a and b to [0..20] each. */

    int g = 0; /* TODO 2: replace with gcd(a, b). */

    /* TODO 3: assert that g divides both a and b. */

    return 0;
}
