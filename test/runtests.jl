using EEG
using Base.Test
using Logging
using MAT, BDF
using SIUnits, SIUnits.ShortUnits
using FileFind
using Plots
using FactCheck
using Suppressor

Logging.configure(level=DEBUG)
Logging.configure(output=open("logfile.log", "a"))
unicodeplots()


#
# Run all tests
#

tests = AbstractString[]
function add_test(fname)
    global tests
    if endswith(fname, ".jl")
        if !contains(fname, "runtests")
            push!(tests, fname)
        end
    end
end
FileFind.find(".", add_test)

for t in tests
    include(t)
end
FactCheck.exitstatus()
