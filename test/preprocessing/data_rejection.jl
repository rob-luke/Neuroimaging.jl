using EEG
using Base.Test
using Logging
Logging.configure(level=DEBUG)


#######################################
#
# Test channel rejection
#
#######################################

# Input
fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)
s = rereference(s, "Cz")
s = channel_rejection(s)

@test size(s.data,1) == 237568
@test size(s.data,2) == 4

println()
println("!! Data rejection tests passed !!")
println()
