@testset "Coordinates" begin

    @testset "Create" begin
        @testset "Brain Vision" begin
            bv = BrainVision(0, 0, 0)
            @testset "Show" begin
                 show(bv)
            end
        end
        @testset "Talairach" begin
            tal = Talairach(68.3, -26.9, 8.3)
            @testset "Show" begin
                 show(tal)
            end
        end
        @testset "SPM" begin
            spm = SPM(68.3, -26.9, 8.3)
            @testset "Show" begin
                 show(spm)
            end
        end
        @testset "Unknown" begin
            uk = UnknownCoordinate(1.2, 2, 3.2)
            @testset "Show" begin
                 show(uk)
            end
        end
    end


    @testset "Convert" begin
        @testset "MNI -> Talairach" begin

            # Values from table IV in Lancaster et al 2007
            # TODO Find better points to translate

            mni = SPM(73.7, -26.0, 7.0)
            tal = Talairach(68.3, -26.9, 8.3)
            @test isapprox(euclidean(convert(Talairach, mni), tal), 0; atol=2)

            # As an electrode

            # Test as an electrode
            e = Electrode("test", SPM(73.7, -26.0, 7.0), Dict())
            e = conv_spm_mni2tal(e)

            @test isapprox(e.coordinate.x, tal.x; atol = 1.5)
            @test isapprox(e.coordinate.y, tal.y; atol = 1.5)
            @test isapprox(e.coordinate.z, tal.z; atol = 1.5)
            @test isa(e, EEG.Sensor) == true
            @test isa(e, EEG.Electrode) == true
            @test isa(e.coordinate, EEG.Talairach) == true

        end

        @testset "BrainVision -> Talairach" begin

            # TODO this just tests it runs, need to check values

            bv = BrainVision(0, 0, 0)
            tal = Talairach(128, 128, 128)
            @test isapprox(euclidean(convert(Talairach, bv), tal), 0; atol=1.5)

        end
    end


    @testset "Distances" begin

        @test euclidean(Talairach(0, 0, 0), Talairach(1, 1, 1)) == sqrt.(3)

        v = [0, 0, 0]
        @test euclidean(Talairach(1, 1, 1), v) == sqrt.(3)
        @test euclidean(v, Talairach(1, 1, 1)) == sqrt.(3)

    end
end
