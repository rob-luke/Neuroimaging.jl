Logging.configure(level=DEBUG)

fname = joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)

@test samplingrate(s) == 8192.0
@test samplingrate(Int, s) == 8192
@test isa(samplingrate(s), AbstractFloat)
@test isa(samplingrate(Int, s), Int)

@test modulationrate(s) == 19.5
@test isa(modulationrate(s), AbstractFloat)

s2 = hcat(deepcopy(s), deepcopy(s))

@test size(s2.data, 1) == 2 * size(s.data, 1)
@test size(s2.data, 2) == size(s.data, 2)
