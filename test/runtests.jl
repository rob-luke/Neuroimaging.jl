using EEG
using Test
using Logging
using MAT, BDF
using Plots
using Glob
using DataDeps

unicodeplots()


#
# Run all tests
#

println(pwd())
tests = glob("**/*.jl")
tests = tests[.~(tests .== "runtests.jl")]

@info tests
for t in tests
    include(t)
end
