using EEG
using Test
using Logging
using MAT, BDF
using Plots
using Eglob

unicodeplots()


#
# Run all tests
#

tests = [match for match in eglob("**/*.jl")]
tests = tests[.~(tests .== "runtests.jl")]

@info tests
for t in tests
    include(t)
end
