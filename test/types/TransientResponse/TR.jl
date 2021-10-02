@testset "Transient Responses" begin

    fname = joinpath(dirname(@__FILE__), "..", "..", "data", "test_Hz19.5-testing.bdf")
    fname2 = joinpath(dirname(@__FILE__), "..", "..", "data", "tmp", "test_Hz19.5-copy.bdf")
    fname_out = joinpath(dirname(@__FILE__), "..", "..", "data", "tmp", "testwrite.bdf")
    cp(fname, fname2, force = true)  # So doesnt use .mat file



    @testset "Read file" begin

        s = read_TR(fname)

        @test isa(s, NeuroimagingMeasurement)
        @test isa(s, EEG)
        @test isa(s, TR)

        s = read_TR(fname2)

        @test samplingrate(s) == 8192.0u"Hz"
        @test samplingrate(Int, s) == 8192
        @test isa(samplingrate(Float64, s), AbstractFloat) == true
        @test isa(samplingrate(Int, s), Int) == true

        @test isapprox(maximum(s.data[:, 2]), 54.5939; atol = 0.1)
        @test isapprox(minimum(s.data[:, 4]), -175.2503; atol = 0.1)

        s = read_TR(fname, valid_triggers = [8])
        s = read_TR(fname, min_epoch_length = 8388)
        s = read_TR(fname, max_epoch_length = 8389)

        s = read_TR(fname)
        original_length = length(s.triggers["Index"])
        s = read_TR(fname, remove_first = 10)
        @test original_length - 10 == length(s.triggers["Index"])

        s = read_TR(fname, max_epochs = 12)
        @test length(s.triggers["Index"]) == 12

        s = read_TR(fname)
        s.triggers = extra_triggers(s.triggers, 1, 7, 0.7, samplingrate(Float64, s))
        @test length(s.triggers["Index"]) == 56
    end

    @testset "Show" begin

        s = read_TR(fname)
        show(s)

    end

    @testset "Plot" begin
        s = read_TR(fname)
        Neuroimaging.plot(s)
        Neuroimaging.plot(s, "Cz")
        Neuroimaging.plot(s, ["Cz"])
        Neuroimaging.plot(s, ["Cz", "10Hz_SWN_70dB_R"])
    end


end
