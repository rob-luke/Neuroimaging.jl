@testset "Leadfield" begin

    L = 1

    @testset "Create" begin

        L = Leadfield(rand(2000, 3, 6), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(["Cz","80Hz_SWN_70dB_R","20Hz_SWN_70dB_R","40Hz_SWN_70dB_R","10Hz_SWN_70dB_R","_4Hz_SWN_70dB_R"]))

        @test size(L.L) == (2000, 3, 6)
    end

    @testset "Show" begin

        show(L)
    end

    @testset "Match" begin

        s = read_SSR(joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-testing.bdf"))

        L1 = match_leadfield(L, s)
        @test size(L1.L) == (2000, 3, 6)


        keep_channel!(s, ["Cz","80Hz_SWN_70dB_R","20Hz_SWN_70dB_R","40Hz_SWN_70dB_R"])
        L2 = match_leadfield(deepcopy(L), s)
        @test size(L2.L) == (2000, 3, 4)
        @test L2.L[:, :, 1] == L1.L[:, :, 1]
        @test L2.L[:, :, 2] == L1.L[:, :, 3]
        @test L2.L[:, :, 4] == L1.L[:, :, 6]
        @test L2.sensors == channelnames(s)

        s = merge_channels(s, "Cz", "garbage")
        @test_throws BoundsError match_leadfield(L, s)

        L = Leadfield(rand(2000, 3, 5), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(["Cz","80Hz_SWN_70dB_R","10Hz_SWN_70dB_R","_4Hz_SWN_70dB_R"]))
        @test_throws ErrorException  match_leadfield(L, s)

    end

    @testset "Operations" begin
        ldf = Leadfield(rand(5, 3, 2), collect(1:5.0), collect(1:5.0), collect(1:5.0), ["ch1", "ch2"])

        @testset "Find location" begin
            for n = 1:size(ldf.L, 1)
                @test n == find_location(ldf, Talairach(ldf.x[n], ldf.y[n], ldf.z[n]))
            end

            for n = 1:size(ldf.L, 1)
                @test n == find_location(ldf, Talairach(ldf.x[n]+0.1, ldf.y[n]-0.1, ldf.z[n]))
            end
        end

    end
end
