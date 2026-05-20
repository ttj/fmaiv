/* Day 4 — the counter from Days 1 / 2 / 3, now in C.
 *
 * Same transition system, third encoding. The CBMC harness in
 * counter_check.c calls counter_step in a bounded loop and asserts the
 * same invariant x <= count_max that nuXmv verified on Day 2 and Lean
 * proved by induction on Day 3.
 *
 * Build with any C99 compiler; verify with cbmc (see counter_check.c).
 */

#include <stdbool.h>

#define COUNT_MAX 10

enum mode { MODE_OFF = 0, MODE_ON = 1 };

struct state {
    enum mode mode;
    int x;
};

/* One step of the counter under input `press`. Matches the SMV
 * `next(...)` clauses exactly. */
void counter_step(struct state *s, bool press)
{
    enum mode prev_mode = s->mode;
    int prev_x = s->x;

    if (prev_mode == MODE_OFF && !press) {
        s->mode = MODE_OFF;
        s->x = prev_x;
    } else if (prev_mode == MODE_OFF && press) {
        s->mode = MODE_ON;
        s->x = prev_x;
    } else if (prev_mode == MODE_ON && !press && prev_x < COUNT_MAX) {
        s->mode = MODE_ON;
        s->x = prev_x + 1;
    } else if (prev_mode == MODE_ON && (press || prev_x >= COUNT_MAX)) {
        s->mode = MODE_OFF;
        s->x = 0;
    }
    /* else: no clause matched; leave s unchanged (mirrors SMV `TRUE : ...`). */
}
