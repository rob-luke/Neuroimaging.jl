using EEG
using Base.Test
using Logging

Logging.configure(level=DEBUG)

fname = joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)

@test samplingrate(s) == 8192.0
@test samplingrate(Int, s) == 8192
@test isa(samplingrate(s), FloatingPoint)
@test isa(samplingrate(Int, s), Int)

@test modulationrate(s) == 19.5
@test isa(modulationrate(s), FloatingPoint)
