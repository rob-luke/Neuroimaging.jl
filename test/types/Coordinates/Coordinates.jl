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

            mni = SPM(73.7u"mm", -26.0u"mm", 7.0u"mm")
            tal = Talairach(68.3u"mm", -26.9u"mm", 8.3u"mm")
            mni_converted = convert(Talairach, mni)
            dist = euclidean(mni_converted, tal)
            @test isapprox(dist, 0; atol = 2)

            # As an electrode

            # Test as an electrode
            e = Electrode("test", SPM(73.7u"mm", -26.0u"mm", 7.0u"mm"), Dict())
            e = conv_spm_mni2tal(e)

            @test isapprox(e.coordinate.x, tal.x; atol = 1.5u"m")
            @test isapprox(e.coordinate.y, tal.y; atol = 1.5u"m")
            @test isapprox(e.coordinate.z, tal.z; atol = 1.5u"m")
            @test isa(e, Neuroimaging.Sensor) == true
            @test isa(e, Neuroimaging.Electrode) == true
            @test isa(e.coordinate, Neuroimaging.Talairach) == true

        end

        @testset "BrainVision -> Talairach" begin

            # TODO this just tests it runs, need to check values

            bv = BrainVision(0, 0, 0)
            tal = Talairach(128u"mm", 128u"mm", 128u"mm")
            @test isapprox(euclidean(convert(Talairach, bv), tal), 0; atol = 1.5)

        end
    end


    @testset "Distances" begin

        @test euclidean(Talairach(0, 0, 0), Talairach(1, 1, 1)) == sqrt.(3)

        v = [0, 0, 0]
        @test euclidean(Talairach(1, 1, 1), v) == sqrt.(3)
        @test euclidean(v, Talairach(1, 1, 1)) == sqrt.(3)

    end
end
