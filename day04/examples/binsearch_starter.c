/* Binary search — STARTER. Implement it so the harness verifies.
 *
 *     cbmc binsearch_starter.c binsearch_check.c --unwind 10 --unwinding-assertions
 * CBMC reports VERIFICATION FAILED (it returns -1 for a key that is present)
 * until you implement it. Worked solution: binsearch.c.
 */
int binsearch(const int *a, int n, int key)
{
    /* TODO: binary search a[0..n-1] (sorted); return an index with
       a[i] == key, or -1 if key is absent. Use lo + (hi - lo)/2 for mid. */
    return -1;   /* stub: always claims "not found" */
}
