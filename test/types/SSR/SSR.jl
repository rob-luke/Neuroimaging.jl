fname = joinpath(dirname(@__FILE__),  "..", "..", "data", "test_Hz19.5-testing.bdf")
fname2 = joinpath(dirname(@__FILE__), "..", "..", "data", "tmp", "test_Hz19.5-copy.bdf")

cp(fname, fname2, remove_destination = true)  # So doesnt use .mat file

s = read_SSR(fname2)

@test samplingrate(s) == 8192.0
@test samplingrate(Int, s) == 8192
@test isa(samplingrate(s), AbstractFloat)
@test isa(samplingrate(Int, s), Int)

@test modulationrate(s) == 19.5
@test isa(modulationrate(s), AbstractFloat)

#
# merge channels
#

s = merge_channels(s, "Cz", "MergedCz")
s = merge_channels(s, ["Cz" "10Hz_SWN_70dB_R"], "Merged")

#
# hcat
#


s2 = hcat(deepcopy(s), deepcopy(s))

@test size(s2.data, 1) == 2 * size(s.data, 1)
@test size(s2.data, 2) == size(s.data, 2)

    keep_channel!(s, ["Cz" "10Hz_SWN_70dB_R"])

@test_throws ArgumentError hcat(s, s2)

#
# Test removing channels
#

s = read_SSR(fname)
s = extract_epochs(s)
s = create_sweeps(s, epochsPerSweep = 2)

s2 = deepcopy(s)
remove_channel!(s2, "Cz")
@test size(s2.data, 2) == 5
@test size(s2.processing["epochs"], 3) == 5
@test size(s2.processing["epochs"], 1) == size(s.processing["epochs"], 1)
@test size(s2.processing["epochs"], 2) == size(s.processing["epochs"], 2)
@test size(s2.processing["sweeps"], 3) == 5
@test size(s2.processing["sweeps"], 1) == size(s.processing["sweeps"], 1)
@test size(s2.processing["sweeps"], 2) == size(s.processing["sweeps"], 2)

s2 = deepcopy(s)
remove_channel!(s2, ["10Hz_SWN_70dB_R"])
@test size(s2.data, 2) == 5

s2 = deepcopy(s)
remove_channel!(s2, [2])
@test size(s2.data, 2) == 5
@test s2.data[:, 2] == s.data[:, 3]

s2 = deepcopy(s)
remove_channel!(s2, 3)
@test size(s2.data, 2) == 5
@test s2.data[:, 3] == s.data[:, 4]

s2 = deepcopy(s)
remove_channel!(s2, [2, 4])
@test size(s2.data, 2) == 4
@test s2.data[:, 2] == s.data[:, 3]
@test s2.data[:, 3] == s.data[:, 5]
@test size(s2.processing["epochs"], 3) == 4
@test size(s2.processing["epochs"], 1) == size(s.processing["epochs"], 1)
@test size(s2.processing["epochs"], 2) == size(s.processing["epochs"], 2)
@test size(s2.processing["sweeps"], 3) == 4
@test size(s2.processing["sweeps"], 1) == size(s.processing["sweeps"], 1)
@test size(s2.processing["sweeps"], 2) == size(s.processing["sweeps"], 2)

s2 = deepcopy(s)
remove_channel!(s2, ["Cz", "10Hz_SWN_70dB_R"])
@test size(s2.data, 2) == 4


#
# Test keeping channels
#


s = read_SSR(fname)
s = extract_epochs(s)
s = create_sweeps(s, epochsPerSweep = 2)

println((channelnames(s)))

s2 = deepcopy(s)
remove_channel!(s2, [2, 4])

# Check keeping channel is same as removing channels
s3 = deepcopy(s)
keep_channel!(s3, [1, 3, 5, 6])
@test s3.data == s2.data
@test s3.processing["sweeps"] == s2.processing["sweeps"]

# Check order of removal does not matter
s3 = deepcopy(s)
keep_channel!(s3, [3, 5, 1, 6])
@test s3.data == s2.data
@test s3.processing["sweeps"] == s2.processing["sweeps"]

# Check can remove by name
s3 = deepcopy(s)
keep_channel!(s3, ["20Hz_SWN_70dB_R", "_4Hz_SWN_70dB_R", "Cz", "80Hz_SWN_70dB_R"])
@test s3.data == s2.data
@test s3.processing["sweeps"] == s2.processing["sweeps"]

# Check the order of removal does not matter
s4 = deepcopy(s)
keep_channel!(s4, ["_4Hz_SWN_70dB_R", "20Hz_SWN_70dB_R", "80Hz_SWN_70dB_R", "Cz"])
@test s3.data == s4.data
@test s3.processing["sweeps"] == s4.processing["sweeps"]

#
# Test frequency changes
#

f = assr_frequency([4, 10, 20, 40, 80])

@test f == [3.90625,9.765625,19.53125,40.0390625,80.078125]
