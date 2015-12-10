Logging.configure(level=DEBUG)


fname = joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-testing.bdf")
fname2 = joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-copy.bdf")

cp(fname, fname2, remove_destination = true)  # So doesnt use .mat file

s = read_SSR(fname2)

@test samplingrate(s) == 8192.0
@test samplingrate(Int, s) == 8192
@test isa(samplingrate(s), AbstractFloat)
@test isa(samplingrate(Int, s), Int)

@test modulationrate(s) == 19.5
@test isa(modulationrate(s), AbstractFloat)

s = merge_channels(s, "Cz", "MergedCz")
s = merge_channels(s, ["Cz" "10Hz_SWN_70dB_R"], "Merged")


s2 = hcat(deepcopy(s), deepcopy(s))

@test size(s2.data, 1) == 2 * size(s.data, 1)
@test size(s2.data, 2) == size(s.data, 2)

    keep_channel!(s, ["Cz" "10Hz_SWN_70dB_R"])

@test_throws ArgumentError hcat(s, s2)



#
# Test frequency changes
#

f = assr_frequency([4, 10, 20, 40, 80])

@test f == [3.90625, 9.76563, 19.5313, 40.0391, 80.0781]
