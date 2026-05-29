#!/usr/bin/env python3
"""Pretty-print a CBMC ``--trace`` for the Day-4 counter (counter.c +
counter_check*.c) as a compact "debugger replay" table:

    inputs the attacker CHOSE         |      state CBMC computed
    (press booleans, replayable)      |      (mode, x with bar viz)

Annotations highlight the transitions that matter pedagogically:
  - OFF -> ON / ON -> OFF flips
  - x increments
  - the "reset" step where an in-ON press resets x to 0
  - the violating step (where the assertion fires)

Usage:
    cbmc counter.c counter_check.c --unwind 26 --unwinding-assertions \\
         --trace | python3 scripts/cbmc-trace-replay.py

    # or for the failing-assertion demo on the slide:
    sed 's/s\\.x <= 10/s.x < 10/' counter_check.c > /tmp/strict.c
    cbmc counter.c /tmp/strict.c --unwind 26 --unwinding-assertions --trace \\
        | python3 scripts/cbmc-trace-replay.py

ANSI colour is auto-detected; force on/off with --color / --no-color.
"""
from __future__ import annotations

import argparse
import re
import sys


# ----- styling helpers ---------------------------------------------------

class Style:
    """Tiny ANSI helper."""

    def __init__(self, use_color: bool) -> None:
        self.use = use_color

    def _wrap(self, s: str, code: str) -> str:
        return f"\033[{code}m{s}\033[0m" if self.use else s

    def red(self, s: str) -> str:     return self._wrap(s, "31")
    def green(self, s: str) -> str:   return self._wrap(s, "32")
    def yellow(self, s: str) -> str:  return self._wrap(s, "33")
    def magenta(self, s: str) -> str: return self._wrap(s, "35")
    def cyan(self, s: str) -> str:    return self._wrap(s, "36")
    def dim(self, s: str) -> str:     return self._wrap(s, "2")
    def bold(self, s: str) -> str:    return self._wrap(s, "1")


# ----- trace parser ------------------------------------------------------

STATE_RE = re.compile(r"^State \d+ file (\S+).*?function (\w+).*?line (\d+)")
ASSIGN_RE = re.compile(r"^  ([\w.]+)=(\S+)")
VIOL_RE = re.compile(r"^Violated property:")


def parse_trace(lines):
    """Walk a CBMC --trace text dump; return (rows, violation_block)."""
    rows = []
    cur = _new_row(step=0, mode="OFF", x=0)
    last_mode, last_x = "OFF", 0
    cur_file = ""
    cur_line = 0
    violation = []

    i = 0
    while i < len(lines):
        ln = lines[i]
        m = STATE_RE.match(ln)
        if m:
            cur_file = m.group(1)
            cur_line = int(m.group(3))
            i += 1
            continue
        if VIOL_RE.match(ln):
            if cur["step"] > 0:
                rows.append(cur)
            violation = lines[i:i + 5]
            break
        am = ASSIGN_RE.match(ln)
        if am:
            lhs, rhs = am.group(1), am.group(2)
            if lhs == "i" and rhs.isdigit() and "check" in cur_file and cur_line == 51:
                if cur["step"] > 0:
                    rows.append(cur)
                cur = _new_row(step=int(rhs) + 1, mode=last_mode, x=last_x)
            elif lhs == "press" and "check" in cur_file and cur_line == 52:
                cur["press"] = rhs.upper()
            elif lhs == "s.mode" and "counter.c" in cur_file:
                new_mode = "ON" if "MODE_ON" in rhs else "OFF"
                if new_mode != cur["mode"]:
                    cur["mode_changed"] = True
                cur["mode"] = new_mode
                last_mode = new_mode
            elif lhs == "s.x" and "counter.c" in cur_file and rhs.isdigit():
                new_x = int(rhs)
                if new_x == 0 and cur["x"] > 0:
                    cur["reset"] = True
                if new_x != cur["x"]:
                    cur["x_changed"] = True
                cur["x"] = new_x
                last_x = new_x
        i += 1

    return rows, violation


def _new_row(step, mode, x):
    return {
        "step": step,
        "press": None,
        "mode": mode,
        "x": x,
        "mode_changed": False,
        "x_changed": False,
        "reset": False,
    }


# ----- rendering ---------------------------------------------------------

WIDTH = 10  # bar width = x max


def render_bar(x):
    filled = max(0, min(x, WIDTH))
    return "#" * filled + "." * (WIDTH - filled)


def render_press(p, st):
    if p == "TRUE":
        return st.magenta(st.bold(">> PRESS"))
    if p == "FALSE":
        return st.dim("   wait ")
    return st.dim("   ?    ")


def render_mode(m, st):
    return st.green(st.bold(" ON")) if m == "ON" else st.dim("OFF")


def render_row(row, st):
    is_viol = row["x"] >= 10
    step_s = f"{row['step']:4d}"
    press_s = render_press(row["press"], st)
    mode_s = render_mode(row["mode"], st)
    x_s = f"{row['x']:2d}"
    bar_s = render_bar(row["x"])

    notes = []
    if row["mode_changed"]:
        notes.append(st.yellow("OFF -> ON" if row["mode"] == "ON" else "ON -> OFF"))
    if row["reset"]:
        notes.append(st.yellow(st.bold("RESET (x=0)")))
    elif row["x_changed"] and row["mode"] == "ON" and row["x"] > 0:
        notes.append(st.cyan(f"x++ -> {row['x']}"))
    if is_viol:
        notes.append(st.red(st.bold("<<< VIOLATED: s.x = 10")))

    step_c = st.red(st.bold(step_s)) if is_viol else step_s
    bar_c = st.red(bar_s) if is_viol else (st.green(bar_s) if row["x"] > 0 else st.dim(bar_s))

    note_s = "  ".join(notes)
    return f"  {step_c}  |  {press_s}  |  {mode_s}  x={x_s}  [{bar_c}]  |  {note_s}"


def print_report(rows, violation, st):
    bar_line = "=" * 88
    print()
    print(st.bold(bar_line))
    print(st.bold("  CBMC counterexample replay -- counter.c + counter_check_strict.c"))
    print(st.bold(bar_line))
    print()
    print(f"  Initial state:  mode = {st.dim('OFF')}    x = {st.dim('0')}    "
          + st.dim("(counter_check.c line 49)"))
    print()
    print(f"  {st.bold('step')}  |  {st.bold('attacker INPUT')}  |  {st.bold('state CBMC COMPUTED')}                    |  {st.bold('transition')}")
    print("  -----+--------------+----------------------------------------+-------------------------------")
    for r in rows:
        print(render_row(r, st))
    print()
    print(st.bold("  ASSERTION FIRED"))
    for v in violation:
        if v.strip():
            print(f"    {v}")
    print()
    print(st.bold("  HOW TO READ THIS"))
    n = len(rows)
    rules = [
        "Only the `>> PRESS` / `wait` column is an INPUT the attacker chose.",
        f"Replay those {n} booleans against counter.c and the bug reproduces deterministically.",
        "Everything else -- mode flips, x climb, the reset -- is computed by counter_step().",
        "CBMC found the shortest press sequence that drives x to 10 within the unwind bound.",
        "Fix:  restore the harness assertion to `s.x <= 10` -- the original property the deck verifies.",
    ]
    for r in rules:
        print(f"    {st.dim('-')} {r}")
    print()


# ----- main --------------------------------------------------------------

def main(argv):
    ap = argparse.ArgumentParser(description="Pretty-print a CBMC counter trace.")
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--color", action="store_true", help="force ANSI colour on")
    g.add_argument("--no-color", action="store_true", help="force ANSI colour off")
    args = ap.parse_args(argv[1:])

    use_color = sys.stdout.isatty()
    if args.color:    use_color = True
    if args.no_color: use_color = False

    st = Style(use_color)
    rows, violation = parse_trace(sys.stdin.read().splitlines())
    if not rows:
        print("(no loop iterations found in trace -- did you pass --trace to cbmc?)",
              file=sys.stderr)
        return 1
    print_report(rows, violation, st)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
