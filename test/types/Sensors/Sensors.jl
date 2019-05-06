@testset "Sensors" begin

    fname = joinpath(dirname(@__FILE__), "..", "..", "data", "test.sfp")
    s = read_sfp(fname)


    @testset "Read file" begin

        s = read_sfp(fname)
        @test length(s) == 3
    end


    @testset "Show" begin

        show(s)
        show(s[1])
    end


    @testset "Info" begin

        @test label(s) == ["Fp1", "Fpz", "Fp2"]
        @test label(s[1]) == "Fp1"
        @test labels(s) == ["Fp1", "Fpz", "Fp2"]
        @test labels(s[1]) == "Fp1"

        @test EEG.x(s) == [-27.747648, -0.085967, 27.676888]
        @test EEG.x(s[1]) == -27.747648

        @test EEG.y(s) == [98.803864, 103.555275, 99.133354]
        @test EEG.y(s[1]) == 98.803864

        @test EEG.z(s) == [34.338360, 34.357265, 34.457005]
        @test EEG.z(s[1]) == 34.338360
    end

    @testset "Matching" begin

        a, b = match_sensors(s, ["Fp1", "Fp2"])

    end


    @testset "Leadfield matching" begin

        L = ones(4, 3, 5)
        L[:, :, 2] = L[:, :, 2] * 2
        L[:, :, 3] = L[:, :, 3] * 3
        L[:, :, 4] = L[:, :, 4] * 4
        L[:, :, 5] = L[:, :, 5] * 5

        L, idx = match_sensors(L, ["meh", "Cz", "Fp1", "Fp2", "eh"], ["Fp2", "Cz"])

        @test size(L) == (4, 3, 2)
        @test L[:, :, 1] == ones(4, 3) * 4
        @test L[:, :, 2] == ones(4, 3) * 2
        @test idx == [4, 2]

    end


    @testset "Standard sets" begin

        @test length(EEG_64_10_20) == 64
        @test length(EEG_Vanvooren_2014) == 18
        @test length(EEG_Vanvooren_2014_Left) == 9
        @test length(EEG_Vanvooren_2014_Right) == 9

    end

end
