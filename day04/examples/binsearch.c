/* Binary search over a sorted array (implementation under verification).
 *
 * Returns an index i with a[i] == key, or -1 if key is absent. The midpoint
 * is computed as lo + (hi - lo)/2 — the overflow-safe form. The famous bug
 * (Java/JDK, 2006) used (lo + hi)/2, which overflows for large indices; try
 * that variant and a wide index range to see CBMC flag it.
 *
 * Verified against binsearch_check.c with CBMC.
 */
int binsearch(const int *a, int n, int key)
{
    int lo = 0;
    int hi = n - 1;
    while (lo <= hi) {
        int mid = lo + (hi - lo) / 2;   /* overflow-safe midpoint */
        if (a[mid] == key) {
            return mid;
        } else if (a[mid] < key) {
            lo = mid + 1;
        } else {
            hi = mid - 1;
        }
    }
    return -1;
}
