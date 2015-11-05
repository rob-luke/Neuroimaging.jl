using EEG
using Base.Test
using Logging
using MAT, BDF
using SIUnits, SIUnits.ShortUnits
using FileFind

Logging.configure(level=DEBUG)


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


#
# Check /test file structure matches /src
#

missing = AbstractString[]
function match_tests(fname)
    global missing

    excluded = ["src/EEG.jl", "src/create_docs.jl", "runtests.jl"]

    if endswith(fname, ".jl")
        if !contains(fname, excluded[1]) & !contains(fname, excluded[2]) & !contains(fname, excluded[3])
            matched = replace(fname, "/src/", "/test/")
            if !isfile(matched)
                println("Missing file: $matched")
                push!(missing, matched)
            end
        end
    end
end

FileFind.find("/Users/rluke/.julia/v0.4/EEG/src/", match_tests)

@test length(missing) <= 1
