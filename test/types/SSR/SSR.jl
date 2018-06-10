facts("Steady State Responses") do

    fname = joinpath(dirname(@__FILE__),  "..", "..", "data", "test_Hz19.5-testing.bdf")
    fname2 = joinpath(dirname(@__FILE__), "..", "..", "data", "tmp", "test_Hz19.5-copy.bdf")
    fname_out = joinpath(dirname(@__FILE__), "..", "..", "data", "tmp", "testwrite.bdf")
    cp(fname, fname2, remove_destination = true)  # So doesnt use .mat file
    s = read_SSR(fname)

    context("Show") do

        @suppress_out show(s)

    end

    context("Read file") do

    	s = read_SSR(fname2)

    	@fact samplingrate(s) --> 8192.0
    	@fact samplingrate(Int, s) --> 8192
    	@fact isa(samplingrate(s), AbstractFloat) --> true
    	@fact isa(samplingrate(Int, s), Int) --> true

    	@fact modulationrate(s) --> 19.5
    	@fact isa(modulationrate(s), AbstractFloat) --> true

        @fact maximum(s.data[:,2]) --> roughly(54.5939, atol =  0.1)
        @fact minimum(s.data[:,4]) --> roughly(-175.2503 , atol = 0.1)

        s = read_SSR(fname, valid_triggers = [8])
        s = read_SSR(fname, min_epoch_length = 8388)
        s = read_SSR(fname, max_epoch_length = 8389)

        s = read_SSR(fname)
        original_length = length(s.triggers["Index"])
        s = read_SSR(fname, remove_first = 10)
        @test original_length - 10 == length(s.triggers["Index"])

        s = read_SSR(fname, max_epochs = 12)
        @test length(s.triggers["Index"]) == 12

        s = read_SSR(fname)
        s.triggers = extra_triggers(s.triggers, 1, 7, 0.7, samplingrate(s))
        @test length(s.triggers["Index"]) == 56
    end


    context("Channel names") do

        s1 = deepcopy(s)
        s1 = channelnames(s1, 1, "A01")
        s1 = channelnames(s1, 2, "A05")
        s1 = channelnames(s1, 3, "A11")
        s1 = channelnames(s1, 4, "B03")
        s1 = channelnames(s1, 5, "A17")
        s1 = channelnames(s1, 6, "B17")
        @fact channelnames(s1) --> ["A01", "A05", "A11", "B03", "A17", "B17"]

    end

    context("Triggers") do

        dats, evtTab, trigs, statusChan = readBDF(fname);
        sampRate = readBDFHeader(fname)["sampRate"][1]

        @fact trigs --> create_channel(evtTab, dats, sampRate, code="code", index="idx", duration="dur")
        @fact trigs --> not(trigger_channel(read_SSR(fname)))
        @fact trigs --> trigger_channel(read_SSR(fname, valid_triggers = collect(-1000:10000)))

        # Convert between events and channels

        dats, evtTab, trigs, statusChan = readBDF(fname);
        events  = create_events(trigs, sampRate)
        channel = create_channel(events, dats, sampRate)

        @fact size(channel) --> size(trigs)
        @fact channel --> trigs

    end


    context("Extra Triggers") do

        s = read_SSR(fname)

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

        @fact_throws BoundsError epoch_rejection(s, retain_percentage = 1.1)
        @fact_throws BoundsError epoch_rejection(s, retain_percentage = -0.1)

    	for r in 0.1 : 0.1 : 1

    	    s = extract_epochs(s)

    	    s = epoch_rejection(s, retain_percentage = r)

    	    @fact floor(28 * r) --> size(s.processing["epochs"], 2)

    	end
    end


    context("Channel rejection") do

        s1 = channel_rejection(deepcopy(s))
        @fact size(s1.processing["epochs"]) --> (8388, 28, 5)

        data = randn(400, 10) * diagm([1, 1, 2, 1, 11, 1, 2, 100, 1, 1])
        valid = channel_rejection(data, 20, 1)
        @fact valid --> [ true  true  true  true  false  true  true  false  true  true]

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

        s = read_SSR(fname)
	    s = extract_epochs(s)
        s = create_sweeps(s; epochsPerSweep=4)
        @fact size(s.processing["sweeps"]) --> (33552,7,6)
        julia_result = average_epochs(s.processing["sweeps"])

        filen = matopen(joinpath(dirname(@__FILE__), "..", "..", "data", "sweeps.mat"))
        matlab_sweeps = read(filen, "sweep")
        close(filen)
        @fact size(matlab_sweeps[:,1:6]) -->  size(julia_result)
        @fact matlab_sweeps[:,1:6] -->  roughly(julia_result, atol = 0.01)  # why so different?

    end


    context("Low pass filter") do

    	s2 = lowpass_filter(deepcopy(s))

    end


    context("High pass filter") do

    	s2 = highpass_filter(deepcopy(s))

    end


    context("Band pass filter") do

    	s2 = bandpass_filter(deepcopy(s))

    end


    context("Downsample") do

    	s2 = downsample(deepcopy(s), 1//4)
    	@fact size(s2.data, 1) --> div(size(s.data, 1), 4)

    end


    context("Rereference") do

        s2 = rereference(deepcopy(s), "Cz")

        @fact size(s2.data,1) --> 237568
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

    context("Write files") do

        s  = read_SSR(fname)
        s.header["subjID"] = "test"
        write_SSR(s, fname_out)
        s  = read_SSR(fname, valid_triggers = collect(-1000:10000))
        s.header["subjID"] = "test"
        write_SSR(s, fname_out)
        s2 = read_SSR(fname_out, valid_triggers = collect(-1000:10000))

        @fact s.data --> s2.data
        @fact s.triggers --> s2.triggers
        @fact s.samplingrate --> s2.samplingrate
        @fact contains(s2.header["subjID"], "test") --> true

        s = channelnames(s, ["B24", "B16", "A3", "B18", "A02", "B17"])
        write_SSR(s, fname_out)
        s2 = read_SSR(fname_out)
        @fact channelnames(s2) --> ["CP2", "Cz", "AF3", "C4", "AF7", "C2"]

    end

    context("Ftest") do

        s = read_SSR(fname)
        s.modulationrate = 19.5
        s = rereference(s, "Cz")
        s = extract_epochs(s)
        s = create_sweeps(s, epochsPerSweep=4)
        snrDb, signal_phase, signal_power, noise_power, statistic = ftest(s.processing["sweeps"], 40.0391, 8192, 2.5, nothing, 2)

        @fact isnan(snrDb[1]) --> true
        @fact isnan(statistic[1]) --> true
        @fact snrDb[2:end] --> roughly([-7.0915, -7.8101, 2.6462, -10.2675, -4.1863]; atol =  0.001)
        @fact statistic[2:end] --> roughly([0.8233,  0.8480, 0.1721,   0.9105,  0.6854]; atol = 0.001)

        s = ftest(s, side_freq=2.5,  Note="Original channels", Additional_columns = 22)
        @fact isnan(s.processing["statistics"][:SNRdB][1]) --> true
        @fact s.processing["statistics"][:SNRdB][2:end] --> roughly([-1.2386, 0.5514, -1.5537, -2.7541, -6.7079]; atol = 0.001)

        s = ftest(s, side_freq = 1.2,  Note="SecondTest", Additional_columns = 24)

        context("Save results") do

            save_results(s)
        end
    end


    context("Adding triggers") do

        for rate in [4, 10, 20, 40]

            s = read_SSR(fname)
            s.modulationrate = rate
            s = add_triggers(s)
            s = extract_epochs(s)
            @fact size(s.processing["epochs"], 1) * rate / 8192 --> roughly(1; atol=0.005)

        end
    end

end
