using Neuroimaging
using Test
using Logging
using MAT
using Plots
using Glob
using DataDeps

include("../src/external/BDF.jl")
using .BDF

unicodeplots()
logger = SimpleLogger(stdout, Logging.Warn)

#
# Run all tests
#

tests = glob("**/*.jl")
tests = tests[.~(tests .== "runtests.jl")]

with_logger(logger) do
    for t in tests
        include(t)
    end
end
