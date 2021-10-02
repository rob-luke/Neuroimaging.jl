using Neuroimaging, Test, BDF

@testset "GeneralEEG" begin

    fname = joinpath(dirname(@__FILE__), "..", "..", "data", "test_Hz19.5-testing.bdf")

    s = read_EEG(fname)

    @test isa(s, NeuroimagingMeasurement)
    @test isa(s, EEG)

    @testset "Plot" begin
        plot(s)
        Neuroimaging.plot(s, "Cz")
        Neuroimaging.plot(s, ["Cz"])
        Neuroimaging.plot(s, ["Cz", "10Hz_SWN_70dB_R"])
    end

    @testset "Show" begin
        show(s)
    end

    @testset "Data" begin

        d = data(s)
        @test size(d) == (237568, 6)

        d = data(s, "Cz")
        @test size(d) == (237568, 1)
        s2 = read_EEG(fname)
        @test data(keep_channel!(s2, "Cz")) == data(s, "Cz")

        d = data(s, ["Cz", "10Hz_SWN_70dB_R"])
        @test size(d) == (237568, 2)
        @test data(keep_channel!(read_EEG(fname), ["Cz", "10Hz_SWN_70dB_R"])) ==
              data(s, ["Cz", "10Hz_SWN_70dB_R"])

        @test_throws KeyError data(s, ["Czghdf", "10Hz_SWN_70dB_R"])
    end

    @testset "Read file" begin

        s = read_EEG(fname)

        @test samplingrate(s) == 8192.0u"Hz"
        @test samplingrate(Int, s) == 8192
        @test isa(samplingrate(Float64, s), AbstractFloat) == true
        @test isa(samplingrate(Int, s), Int) == true

        @test isapprox(maximum(s.data[:, 2]), 54.5939; atol = 0.1)
        @test isapprox(minimum(s.data[:, 4]), -175.2503; atol = 0.1)

        s = read_EEG(fname, valid_triggers = [8])
        s = read_EEG(fname, min_epoch_length = 8388)
        s = read_EEG(fname, max_epoch_length = 8389)

        s = read_EEG(fname)
        original_length = length(s.triggers["Index"])
        s = read_EEG(fname, remove_first = 10)
        @test original_length - 10 == length(s.triggers["Index"])

        s = read_EEG(fname, max_epochs = 12)
        @test length(s.triggers["Index"]) == 12

        s = read_EEG(fname)
        s.triggers = extra_triggers(s.triggers, 1, 7, 0.7, samplingrate(Float64, s))
        @test length(s.triggers["Index"]) == 56
    end


    @testset "Sensors" begin

        s1 = sensors(deepcopy(s))
        @test length(s1) == 6
        @test length(x(s1)) == 6
        @test length(labels(s1)) == 6

    end


    @testset "Channel names" begin

        s1 = deepcopy(s)
        s1 = channelnames(s1, 1, "A01")
        s1 = channelnames(s1, 2, "A05")
        s1 = channelnames(s1, 3, "A11")
        s1 = channelnames(s1, 4, "B03")
        s1 = channelnames(s1, 5, "A17")
        s1 = channelnames(s1, 6, "B17")
        @test channelnames(s1) == ["A01", "A05", "A11", "B03", "A17", "B17"]

    end


    @testset "Low pass filter" begin
        s = read_EEG(fname)
        s2 = filter_lowpass(deepcopy(s))
        s2 = filter_lowpass(deepcopy(s))
        s2 = filter_lowpass(deepcopy(s), cutOff = 3u"Hz")
        @test_throws ArgumentError filter_lowpass(deepcopy(s), phase = "bad")

    end


    @testset "High pass filter" begin
        s = read_EEG(fname)
        s2 = filter_highpass(deepcopy(s))
        s2 = filter_highpass(deepcopy(s), cutOff = 3u"Hz")
        @test_throws ArgumentError filter_highpass(deepcopy(s), phase = "bad")
    end


    @testset "Band pass filter" begin
        s = read_EEG(fname)
        s2 = filter_bandpass(deepcopy(s), 3u"Hz", 200u"Hz")
        @test_throws ArgumentError filter_bandpass(
            deepcopy(s),
            3u"Hz",
            200u"Hz",
            phase = "bad",
        )

    end

    @testset "Triggers" begin

        dats, evtTab, trigs, statusChan = readBDF(fname)
        sampRate = readBDFHeader(fname)["sampRate"][1]

        @test trigs == create_channel(
            evtTab,
            dats,
            sampRate,
            code = "code",
            index = "idx",
            duration = "dur",
        )
        @test trigs ==
              trigger_channel(read_EEG(fname, valid_triggers = collect(-1000:10000)))

        # Convert between events and channels

        dats, evtTab, trigs, statusChan = readBDF(fname)
        events = create_events(trigs, sampRate)
        channel = create_channel(events, dats, sampRate)

        @test size(channel) == size(trigs)
        @test channel == trigs

    end


end
