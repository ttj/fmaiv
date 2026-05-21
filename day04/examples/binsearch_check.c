/* CBMC harness for binsearch.c.
 *
 * CBMC picks an arbitrary array and key, ASSUMES the array is sorted
 * (non-decreasing), then checks full functional correctness for every such
 * input of size N:
 *   - if binsearch returns r >= 0, then r is in range and a[r] == key;
 *   - if it returns -1, then key really is absent from the array.
 *
 * Verify:
 *     cbmc binsearch.c binsearch_check.c --unwind 10 --unwinding-assertions
 * Expected:  VERIFICATION SUCCESSFUL
 *
 * (`__CPROVER_assume` restricts CBMC to sorted inputs. Remove that loop and the
 * "not found => absent" property no longer holds — CBMC will produce an
 * unsorted counterexample.)
 */
#include <assert.h>

#define N 5

int binsearch(const int *a, int n, int key);
int nondet_int(void);

int main(void)
{
    int a[N];
    for (int i = 0; i < N; ++i) {
        a[i] = nondet_int();
    }
    /* Assume the array is sorted non-decreasing. */
    for (int i = 0; i + 1 < N; ++i) {
        __CPROVER_assume(a[i] <= a[i + 1]);
    }

    int key = nondet_int();
    int r = binsearch(a, N, key);

    if (r >= 0) {
        assert(r < N);
        assert(a[r] == key);
    } else {
        /* Not found: the key appears nowhere. */
        for (int i = 0; i < N; ++i) {
            assert(a[i] != key);
        }
    }

    return 0;
}
