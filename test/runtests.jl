using EEG
using Test
using Logging
using MAT, BDF
using Plots
using Glob
using Suppressor
using Printf

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


for (root, dirs, files) in walkdir(".")
    for file in files
        if endswith(file, ".jl")
            if !contains(file, "runtests")
                push!(tests, joinpath(root, file))
            end
        end
    end
end

for t in tests
    println("Testing $t")
    include(t)
end
