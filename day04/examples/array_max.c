/* Maximum of an array (implementation under verification).
 * Verified against array_max_check.c with CBMC. */
int array_max(const int *a, int n)
{
    int m = a[0];
    for (int i = 1; i < n; ++i) {
        if (a[i] > m) {
            m = a[i];
        }
    }
    return m;
}
