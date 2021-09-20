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

    s = trim_channel(s, 8192 * 3)

    @testset "Multi channel time series" begin
        plot1 = plot_timeseries(s)
        #= display(plot1) =#

        plot2 = plot_timeseries(s, channels = ["40Hz_SWN_70dB_R", "Cz"])
        #= display(plot2) =#

        s = rereference(s, "car")
        plot3 = plot_timeseries(s, channels = ["40Hz_SWN_70dB_R", "Cz"])
        #= display(plot3) =#
    end

    @testset "Single channel time series" begin
        plot4 = plot_timeseries(s, channels = ["40Hz_SWN_70dB_R"])
        #= display(plot4) =#

        plot5 = plot_timeseries(s, channels = "Cz")
        #= display(plot5) =#

        keep_channel!(s, ["40Hz_SWN_70dB_R"])
        plot6 = plot_timeseries(s)
        #= display(plot6) =#
    end
end
