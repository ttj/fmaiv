/* Maximum of an array — STARTER. Implement it so the harness verifies.
 *
 *     cbmc array_max_starter.c array_max_check.c --unwind 6 --unwinding-assertions
 * CBMC reports VERIFICATION FAILED with a counterexample until you implement
 * this correctly. Worked solution: array_max.c.
 */
int array_max(const int *a, int n)
{
    /* TODO: scan a[0..n-1] and return the largest element. */
    return a[0];   /* stub: wrong whenever the max is not the first element */
}
