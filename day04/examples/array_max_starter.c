/* Maximum of an array — STARTER. Implement it so the harness verifies.
 *
 *     cbmc array_max_starter.c array_max_check.c --unwind 6 --unwinding-assertions
 * CBMC reports VERIFICATION FAILED with a counterexample until you implement
 * this correctly. Worked solution: array_max.c.
 */
/* a = pointer to the first element; n = how many elements; return the largest. */
int array_max(const int *a, int n)
{
    /* TODO: scan a[0..n-1] and return the largest element. */
    /* YOUR JOB: keep a running maximum. Start it at a[0], then loop over the
     * remaining elements (i = 1 .. n-1); whenever a[i] is bigger, update the
     * max. The stub below only ever returns the FIRST element, so CBMC finds an
     * array whose true max is elsewhere and reports VERIFICATION FAILED with a
     * counterexample. Once you scan the whole array it becomes SUCCESSFUL. */
    return a[0];   /* stub: wrong whenever the max is not the first element */
}
