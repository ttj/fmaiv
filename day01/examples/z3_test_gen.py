from z3 import *

# test generation for a function GCD(x, y): computes greatest common denominator of x and y by Euclid's algorithm and updates y with the GCD

opt_integer = 1

if opt_integer:
    x = Function('x', IntSort(), IntSort()) # function mapping integers to integers; input argument
    y = Function('y', IntSort(), IntSort()) # function mapping integers to integers; input argument and return value
    m = Function('m', IntSort(), IntSort()) # function mapping integers to integers; local variable


# play with the length, tests, and bits parameters to see different program paths with different memory sizes, program path lengths, and numbers of tests

length = 2 # number of loops to unroll / depth of program to explore and get satisfying inputs leading to this depth

tests = 3 # number of tests to generate

bits = 6 # number of bits to use for representing x, y, and m

# add one to the number of bits when using bitvectors (not sure why, maybe they're signed)
if not opt_integer:
    bits = bits + 1

# In general this is not necessary and Z3 can work with unbounded integers; I'm just using this to illustrate there will be a finite number of tests with finite precision.
# Also note that if you want to model bitvectors, you should use the bitvector types instead of integers, as the bitvector solver will be much better for most problems than an integer solver [e.g., nonlinear integer arithmetic is undecidable, but if you're modeling using bits instead of integers, it will be decidable due in part to the finite domain].
# In general, the bitvector solvers are significantly faster than integer solvers.
# To observe this performance difference: toggle the option variable opt_integer from 1 to 0: see how high you can make the length and bits when doing this
#
# Example: try length 5 with 16 bits in integer versus bitvector

if not opt_integer:
    x = Function('x', IntSort(), BitVecSort(bits) )
    y = Function('y', IntSort(), BitVecSort(bits) )
    m = Function('m', IntSort(), BitVecSort(bits) )

s = Solver() # instantiate a solver

if opt_integer:
    s.add((y(0) > 0)) # add a constraint: input requirement: y must be positive
else:
    s.add((y(0) > BitVecVal(0,bits)))

# unroll the loop `length` times
for i in range(length + 1):
    s.add(And (x(i) >= 0, y(i) >= 0, m(i) >= 0)) # datatype assumptions: unsigned
    if opt_integer:     
        s.add(And (x(i) < 2**bits, y(i) < 2**bits, m(i) < 2**bits)) # datatype assumptions: finite precision
        
    
    # gcd program encoding (termination condition not satisfied)
    if i < length:
        s.add( And((m(i) == (x(i) % y(i))), (m(i) != 0), (x(i + 1) == y(i)), (y(i + 1) == m(i))) )
    # gcd program encoding (termination condition satisfied)
    else:
        s.add( And((m(i) == (x(i) % y(i))), (m(i) == 0), (y(i) >= 10) ))
        
print(s)    
    
# Encoding without functions for 2 loops: usually significantly more efficient, can write a script to generate a Python input file with all these variables.
# This is probably how you would want to do this in practice.
#x0, y0, m0, x1, y1, m1 = Ints('x0 y0 m0 x1 y1 m1') # 2 loops
#s.add(And (x0 >= 0, y0 >= 0, m0 >= 0, x1 >= 0, y1 >= 0, m1 >= 0)) # datatype assumptions
#P = And( (y0 > 0), (m0 == (x0 % y0)), (m0 != 0), (x1 == y0), (y1 == m0), (m1 == (x1 % y1)), (m1 == 0))

#print(s)

for t in range(tests):
    i = 0 # constant
    result = s.check() # check if the set of assertions are satisfiable
    
    # if they are satisfiable, use the model values to generate a different test input of the same trace length
    if result == sat:
        model = s.model()
        print(model)
        print("GCD(x,y): GCD(" + str(model.evaluate( x(0) )) + "," + str(model.evaluate( y(0) )) + ") = " + str(model.evaluate( y(length) )) + "\n")
        
        # can specify both x and y are different since GCD(x,y) = GCD(y,x)
        # however: note that this will be a different path through the program (i.e., the path through the program for GCD(y,x) differs from GCD(x,y), so we should check both by specifying the disjunction)
        #s.add( x(i) != model.evaluate( x(i) ) ) # ask for a different input
        #s.add( y(i) != model.evaluate( y(i) ) ) # ask for a different input
        s.add( Or(x(i) != model.evaluate( x(i) ), y(i) != model.evaluate( y(i) )) ) # ask for a different input for either x or y
    # otherwise, there are no more traces
    else:
        print("There are no more traces of length " + str(length) + " (assuming " + str(bits) + " bits.  There were " + str(t) + " traces.")
        print(s.unsat_core())
        break

# We could use this procedure to generate ALL tests (by incrementing the length and checking an arbitrary number of tests), although it would be horribly inefficient.
# For any finite choice of bit representation, the method would terminate.