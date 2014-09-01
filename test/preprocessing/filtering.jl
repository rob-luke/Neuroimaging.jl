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

s = read_ASSR(fname)
s = bandpass_filter(s)

println()
println("!! Data filtering tests passed !!")
println()
