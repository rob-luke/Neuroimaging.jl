@testset "Plotting" begin

    fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")
    s = read_SSR(fname)
    s = rereference(s, "Cz")
    s = filter_highpass(s)
    s = extract_epochs(s)
    s = create_sweeps(s, epochsPerSweep = 2)
    s = ftest(s)

    @testset "Spectrum" begin
        p = plot_spectrum(s, "20Hz_SWN_70dB_R", targetFreq = 3.0)
        #= display(p) =#

        p = plot_spectrum(vec(s.data[:, 1]), samplingrate(Int, s), dBPlot = false)
        #= display(p) =#

        p = plot_spectrum(s, 3, targetFreq = 40.0390625)
        #= display(p) =#
    end

    @testset "Filter reponse" begin

        p = plot_filter_response(s.processing["filter1"], samplingrate(Int, s))
        #= display(p) =#
    end
end
