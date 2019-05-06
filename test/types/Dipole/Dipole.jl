using Unitful

@testset "Dipoles" begin

    dips = Dipole[]

    @testset "Create" begin

        dip1 = Dipole("Talairach", 1u"m", 2u"m", 1u"m", 0, 0, 0, 1, 1, 1)
        dip2 = Dipole("Talairach", 1u"m", 2u"m", 3u"m", 0, 0, 0, 2, 2, 2)

        dips = push!(dips, dip1)
        dips = push!(dips, dip2)

        @test length(dips) == 2
    end

    @testset "Show" begin

        show(dips[1])
        show(dips)
    end


    @testset "Mean" begin

        b = mean(dips)
        @test b.x == 1.0u"m"
        @test b.y == 2.0u"m"
        @test b.z == 2.0u"m"
    end

    @testset "Std" begin

        b = std(dips)
        @test b.x == 0.0u"m"
        @test b.y == 0.0u"m"
        @test b.z == std([1, 3])u"m"
    end
end
