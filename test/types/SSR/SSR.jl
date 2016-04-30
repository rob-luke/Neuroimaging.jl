facts("Steady State Responses") do

    fname = joinpath(dirname(@__FILE__),  "..", "..", "data", "test_Hz19.5-testing.bdf")
    fname2 = joinpath(dirname(@__FILE__), "..", "..", "data", "tmp", "test_Hz19.5-copy.bdf")
    cp(fname, fname2, remove_destination = true)  # So doesnt use .mat file
    s = read_SSR(fname)

    context("Read file") do

	s = read_SSR(fname2)

	@fact samplingrate(s) --> 8192.0
	@fact samplingrate(Int, s) --> 8192
	@fact isa(samplingrate(s), AbstractFloat) --> true
	@fact isa(samplingrate(Int, s), Int) --> true

	@fact modulationrate(s) --> 19.5
	@fact isa(modulationrate(s), AbstractFloat) --> true

    end


    context("Extract epochs") do

	s = extract_epochs(s, valid_triggers=[1, 2])

	@fact size(s.processing["epochs"]) --> (8388,28,6)

	s = extract_epochs(s, valid_triggers = [1])

	@fact size(s.processing["epochs"]) --> (16776,14,6)

	s = extract_epochs(s, valid_triggers = 1)

	@fact size(s.processing["epochs"]) --> (16776,14,6)

	s = extract_epochs(s)

	@fact size(s.processing["epochs"]) --> (8388,28,6)

	if VERSION >= VersionNumber(0, 4, 0)
	    @fact_throws ArgumentError extract_epochs(s, valid_triggers = -4)
	else
	    @fact_throws ErrorException extract_epochs(s, valid_triggers = -4)
	end

    end


    context("Epoch rejection") do

	s = epoch_rejection(s)

	@fact floor(28 * 0.95) --> size(s.processing["epochs"], 2)

	for r in 0.1 : 0.1 : 1

	    s = extract_epochs(s)

	    s = epoch_rejection(s, retain_percentage = r)

	    @fact floor(28 * r) --> size(s.processing["epochs"], 2)

	end
    end


    context("Create sweeps") do

	s = extract_epochs(s)

	@fact_throws ErrorException create_sweeps(s)

	for l in 4 : 4 : 24

	    s = extract_epochs(s)

	    s = create_sweeps(s, epochsPerSweep = l)

	    @fact size(s.processing["sweeps"], 2) --> floor(28 / l)
	    @fact size(s.processing["sweeps"], 1) --> l * size(s.processing["epochs"], 1)
	    @fact size(s.processing["sweeps"], 3) --> size(s.processing["epochs"], 3)
	end
    end


    context("Low pass filter") do

	s2 = lowpass_filter(deepcopy(s))

    end


    context("High pass filter") do

	s2 = highpass_filter(deepcopy(s))

    end


    context("Downsample") do

	s2 = downsample(deepcopy(s), 1//4)
	@fact size(s2.data, 1) --> div(size(s.data, 1), 4)

    end


    context("Merge channels") do

	s2 = merge_channels(deepcopy(s), "Cz", "MergedCz")
	s2 = merge_channels(deepcopy(s), ["Cz" "10Hz_SWN_70dB_R"], "Merged")

    end


    context("Concatenate") do

	s2 = hcat(deepcopy(s), deepcopy(s))

	@fact size(s2.data, 1) --> 2 * size(s.data, 1)
	@fact size(s2.data, 2) --> size(s.data, 2)

	    keep_channel!(s2, ["Cz" "10Hz_SWN_70dB_R"])

	@fact_throws ArgumentError hcat(s, s2)

    end


    context("Remove channels") do

	s = extract_epochs(s)
	s = create_sweeps(s, epochsPerSweep = 2)

	s2 = deepcopy(s)
	remove_channel!(s2, "Cz")
	@fact size(s2.data, 2) --> 5
	@fact size(s2.processing["epochs"], 3) --> 5
	@fact size(s2.processing["epochs"], 1) --> size(s.processing["epochs"], 1)
	@fact size(s2.processing["epochs"], 2) --> size(s.processing["epochs"], 2)
	@fact size(s2.processing["sweeps"], 3) --> 5
	@fact size(s2.processing["sweeps"], 1) --> size(s.processing["sweeps"], 1)
	@fact size(s2.processing["sweeps"], 2) --> size(s.processing["sweeps"], 2)

	s2 = deepcopy(s)
	remove_channel!(s2, ["10Hz_SWN_70dB_R"])
	@fact size(s2.data, 2) --> 5

	s2 = deepcopy(s)
	remove_channel!(s2, [2])
	@fact size(s2.data, 2) --> 5
	@fact s2.data[:, 2] --> s.data[:, 3]

	s2 = deepcopy(s)
	remove_channel!(s2, 3)
	@fact size(s2.data, 2) --> 5
	@fact s2.data[:, 3] --> s.data[:, 4]

	s2 = deepcopy(s)
	remove_channel!(s2, [2, 4])
	@fact size(s2.data, 2) --> 4
	@fact s2.data[:, 2] --> s.data[:, 3]
	@fact s2.data[:, 3] --> s.data[:, 5]
	@fact size(s2.processing["epochs"], 3) --> 4
	@fact size(s2.processing["epochs"], 1) --> size(s.processing["epochs"], 1)
	@fact size(s2.processing["epochs"], 2) --> size(s.processing["epochs"], 2)
	@fact size(s2.processing["sweeps"], 3) --> 4
	@fact size(s2.processing["sweeps"], 1) --> size(s.processing["sweeps"], 1)
	@fact size(s2.processing["sweeps"], 2) --> size(s.processing["sweeps"], 2)

	s2 = deepcopy(s)
	remove_channel!(s2, ["Cz", "10Hz_SWN_70dB_R"])
	@fact size(s2.data, 2) --> 4

    end


    context("Keep channels") do

	s2 = deepcopy(s)
	remove_channel!(s2, [2, 4])

	# Check keeping channel is same as removing channels
	s3 = deepcopy(s)
	keep_channel!(s3, [1, 3, 5, 6])
	@fact s3.data --> s2.data
	@fact s3.processing["sweeps"] --> s2.processing["sweeps"]

	# Check order of removal does not matter
	s3 = deepcopy(s)
	keep_channel!(s3, [3, 5, 1, 6])
	@fact s3.data --> s2.data
	@fact s3.processing["sweeps"] --> s2.processing["sweeps"]

	# Check can remove by name
	s3 = deepcopy(s)
	keep_channel!(s3, ["20Hz_SWN_70dB_R", "_4Hz_SWN_70dB_R", "Cz", "80Hz_SWN_70dB_R"])
	@fact s3.data --> s2.data
	@fact s3.processing["sweeps"] --> s2.processing["sweeps"]

	# Check the order of removal does not matter
	s4 = deepcopy(s)
	keep_channel!(s4, ["_4Hz_SWN_70dB_R", "20Hz_SWN_70dB_R", "80Hz_SWN_70dB_R", "Cz"])
	@fact s3.data --> s4.data
	@fact s3.processing["sweeps"] --> s4.processing["sweeps"]

    end


    context("Frequency fixing") do

	@fact assr_frequency(4) --> 3.90625
	@fact assr_frequency([4, 10, 20, 40, 80]) --> [3.90625,9.765625,19.53125,40.0390625,80.078125]

    end
end
