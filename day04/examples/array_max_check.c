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
#include <assert.h>

#define N 5

int array_max(const int *a, int n);
int nondet_int(void);

int main(void)
{
    int a[N];
    for (int i = 0; i < N; ++i) {
        a[i] = nondet_int();
    }

    int m = array_max(a, N);

    /* (1) m is an upper bound on every element. */
    for (int i = 0; i < N; ++i) {
        assert(m >= a[i]);
    }

    /* (2) m is realized by some element. */
    int found = 0;
    for (int i = 0; i < N; ++i) {
        if (a[i] == m) {
            found = 1;
        }
    }
    assert(found);

    return 0;
}
