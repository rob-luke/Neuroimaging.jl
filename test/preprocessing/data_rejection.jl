using EEG
using Base.Test
using Logging
Logging.configure(level=DEBUG)


#######################################
#
# Test epoch rejection
#
#######################################

fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)
s = rereference(s, "Cz")
s = channel_rejection(s)

@test size(s.data,1) == 237568
@test size(s.data,2) == 4

s = extract_epochs(s)
s = epoch_rejection(s)

@test size(s.processing["epochs"]) == (8388, 25, 4)

@test_throws BoundsError epoch_rejection(s, retain_percentage = 1.1)
@test_throws BoundsError epoch_rejection(s, retain_percentage = -0.1)


#######################################
#
# Test channel rejection
#
#######################################

data = randn(400, 10) * diagm([1, 1, 2, 1, 11, 1, 2, 100, 1, 1])

valid = channel_rejection(data, 20, 1)

@test valid == [ true  true  true  true  false  true  true  false  true  true]


println()
println("!! Data rejection tests passed !!")
println()
