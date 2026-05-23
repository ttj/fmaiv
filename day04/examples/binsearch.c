/* Binary search over a sorted array (implementation under verification).
 *
 * Returns an index i with a[i] == key, or -1 if key is absent. The midpoint
 * is computed as lo + (hi - lo)/2 — the overflow-safe form. The famous bug
 * (Java/JDK, 2006) used (lo + hi)/2, which overflows for large indices; try
 * that variant and a wide index range to see CBMC flag it.
 *
 * Verified against the harness in binsearch_check.c with CBMC:
 *     cbmc binsearch.c binsearch_check.c --unwind 10 --unwinding-assertions
 * (This file alone has no main(); the harness supplies the sorted array + key.)
 */
/* a = sorted (non-decreasing) array; n = its length; key = value to find.
 * Returns an index i with a[i] == key, or -1 if key is not present. */
int binsearch(const int *a, int n, int key)
{
    int lo = 0;                         /* low end of the part we still search */
    int hi = n - 1;                     /* high end (last valid index) */
    while (lo <= hi) {                  /* keep going while the window is non-empty */
        int mid = lo + (hi - lo) / 2;   /* overflow-safe midpoint (see note above on the famous (lo+hi)/2 bug) */
        if (a[mid] == key) {            /* hit the middle exactly */
            return mid;                 /*   -> done, return its index */
        } else if (a[mid] < key) {      /* middle too small */
            lo = mid + 1;               /*   -> key must be in the upper half */
        } else {                        /* middle too big */
            hi = mid - 1;               /*   -> key must be in the lower half */
        }
    }
    return -1;                          /* window emptied without a match: key is absent */
}
