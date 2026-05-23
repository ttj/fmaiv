/* CBMC harness for array_max.c.
 *
 * CBMC fills the array with unconstrained values (nondet_int) and checks the
 * full specification of "maximum" for EVERY possible array of size N:
 *   (1) the result is >= every element, and
 *   (2) the result actually appears in the array.
 *
 * Verify:
 *     cbmc array_max.c array_max_check.c --unwind 6 --unwinding-assertions
 * Expected:  VERIFICATION SUCCESSFUL
 *
 * (Loops run N=5 times, so --unwind 6 = N+1 covers them with the termination
 * check. To see a failure, break the loop bound in array_max.c, e.g. change
 * `i < n` to `i < n - 1`, and CBMC will hand you a counterexample array.)
 */
#include <assert.h>          /* gives us assert(); CBMC turns each assert into a proof goal */

#define N 5                  /* array size used for the proof (small, but covers ALL value combinations) */

int array_max(const int *a, int n);   /* the function we are verifying (defined in array_max.c) */
/* `nondet_int` has NO body here on purpose. CBMC treats any function named
 * nondet_* as "an unconstrained value of that type" -- a FREE INPUT it is
 * allowed to pick any way it likes. So each call below is a fresh wildcard int. */
int nondet_int(void);

int main(void)
{
    int a[N];
    for (int i = 0; i < N; ++i) {
        a[i] = nondet_int();          /* fill the array with arbitrary ints: CBMC checks EVERY possibility */
    }

    int m = array_max(a, N);          /* run the implementation under test */

    /* (1) m is an upper bound on every element. */
    for (int i = 0; i < N; ++i) {
        assert(m >= a[i]);            /* `assert(c)` is the PROPERTY: CBMC must show c holds on all inputs */
    }

    /* (2) m is realized by some element. (Upper bound alone isn't enough --
     * e.g. INT_MAX is >= everything but may not be in the array.) */
    int found = 0;
    for (int i = 0; i < N; ++i) {
        if (a[i] == m) {
            found = 1;                /* mark that m equals some actual element */
        }
    }
    assert(found);                    /* require that m really came from the array */

    return 0;
}
