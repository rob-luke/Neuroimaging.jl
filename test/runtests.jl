using EEG
using Test
using Logging
using MAT, BDF
using Plots

unicodeplots()


#
# Run all tests
#

tests = AbstractString[]

for (root, dirs, files) in walkdir(".")
    for file in files
        @info file
    end
end

#function add_test(fname)
#    global tests
#    if endswith(fname, ".jl")
#        if !contains(fname, "runtests#")
#            push!(tests, fname)
#        end
#    end
#end
#FileFind.find(".", add_test)
#
#for t in tests
#    include(t)
#end
#FactCheck.exitstatus()
