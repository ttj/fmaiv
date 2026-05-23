/* Binary search — STARTER. Implement it so the harness verifies.
 *
 *     cbmc binsearch_starter.c binsearch_check.c --unwind 10 --unwinding-assertions
 * CBMC reports VERIFICATION FAILED (it returns -1 for a key that is present)
 * until you implement it. Worked solution: binsearch.c.
 */
/* a = sorted array; n = length; key = value to find. Return an index of key, or -1. */
int binsearch(const int *a, int n, int key)
{
    /* TODO: binary search a[0..n-1] (sorted); return an index with
       a[i] == key, or -1 if key is absent. Use lo + (hi - lo)/2 for mid. */
    /* YOUR JOB: keep a window [lo, hi] (start lo=0, hi=n-1). Each loop, look at
     * the middle element: if it equals key, return mid; if it's too small,
     * search the upper half (lo = mid+1); if too big, the lower half
     * (hi = mid-1). Stop when lo > hi and return -1. The stub below always says
     * "not found", so CBMC finds a present key and reports VERIFICATION FAILED;
     * a correct search makes it SUCCESSFUL. */
    return -1;   /* stub: always claims "not found" */
}
