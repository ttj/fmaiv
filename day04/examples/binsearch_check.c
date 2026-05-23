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
#include <assert.h>          /* assert(): each one becomes a CBMC proof goal */

#define N 5                  /* array size used for the proof */

int binsearch(const int *a, int n, int key);   /* the function under test (in binsearch.c) */
int nondet_int(void);        /* CBMC wildcard: a free, unconstrained int input (no body needed) */

int main(void)
{
    int a[N];
    for (int i = 0; i < N; ++i) {
        a[i] = nondet_int();          /* arbitrary array contents */
    }
    /* Assume the array is sorted non-decreasing. */
    for (int i = 0; i + 1 < N; ++i) {
        /* `__CPROVER_assume(c)` tells CBMC to ONLY consider inputs where c is
         * true -- it restricts (constrains) the wildcards above. binsearch is
         * only correct on sorted arrays, so we assume sortedness here. (assume
         * filters inputs; assert checks a result -- don't confuse the two.) */
        __CPROVER_assume(a[i] <= a[i + 1]);
    }

    int key = nondet_int();           /* search for an arbitrary key, too */
    int r = binsearch(a, N, key);     /* run the implementation under test */

    if (r >= 0) {                      /* binsearch claims it FOUND the key at index r */
        assert(r < N);                 /*   r must be a valid index (in range) */
        assert(a[r] == key);           /*   and the element there must really equal key */
    } else {                           /* binsearch returned -1, claiming NOT FOUND */
        /* Not found: the key appears nowhere. */
        for (int i = 0; i < N; ++i) {
            assert(a[i] != key);       /*   so no element may equal key (this is where sortedness matters) */
        }
    }

    return 0;
}
