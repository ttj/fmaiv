-- Root module for the FMAIV Day 3 Counter demo.
-- Imports everything so a single `lake build` checks the whole project.
-- `import M` = pull in (compile + make visible) the contents of module M.
-- The order does not matter; Lean figures out dependencies. Start with the
-- shared framework, then each example that builds on it.
import CounterDemo.TransitionSystem
import CounterDemo.Counter
import CounterDemo.ArraySum
import CounterDemo.Gcd
import CounterDemo.Sorting
import CounterDemo.TrafficLight
import CounterDemo.SlideExamples
