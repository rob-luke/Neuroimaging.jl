facts("Leadfield") do

    L = 1

    context("Create") do

        L = Leadfield(rand(2000, 3, 6), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(["Cz","80Hz_SWN_70dB_R","20Hz_SWN_70dB_R","40Hz_SWN_70dB_R","10Hz_SWN_70dB_R","_4Hz_SWN_70dB_R"]))

        @fact size(L.L) --> (2000, 3, 6)
    end

    context("Show") do

        @suppress_out show(L)
    end

    context("Match") do

        s = read_SSR(joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-testing.bdf"))

        L1 = match_leadfield(L, s)
        @fact size(L1.L) --> (2000, 3, 6)


        keep_channel!(s, ["Cz","80Hz_SWN_70dB_R","20Hz_SWN_70dB_R","40Hz_SWN_70dB_R"])
        L2 = match_leadfield(deepcopy(L), s)
        @fact size(L2.L) --> (2000, 3, 4)
        @fact L2.L[:, :, 1] --> L1.L[:, :, 1]
        @fact L2.L[:, :, 2] --> L1.L[:, :, 3]
        @fact L2.L[:, :, 4] --> L1.L[:, :, 6]
        @fact L2.sensors --> channelnames(s)

        s = merge_channels(s, "Cz", "garbage")
        @fact_throws BoundsError match_leadfield(L, s)

        L = Leadfield(rand(2000, 3, 5), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(["Cz","80Hz_SWN_70dB_R","10Hz_SWN_70dB_R","_4Hz_SWN_70dB_R"]))
        @fact_throws ErrorException  match_leadfield(L, s)

    end

    context("Operations") do
        ldf = Leadfield(rand(5, 3, 2), collect(1:5.0), collect(1:5.0), collect(1:5.0), ["ch1", "ch2"])

        context("Find location") do
            for n = 1:size(ldf.L, 1)
                @fact n --> find_location(ldf, Talairach(ldf.x[n], ldf.y[n], ldf.z[n]))
            end

            for n = 1:size(ldf.L, 1)
                @fact n --> find_location(ldf, Talairach(ldf.x[n]+0.1, ldf.y[n]-0.1, ldf.z[n]))
            end
        end

    end
end
