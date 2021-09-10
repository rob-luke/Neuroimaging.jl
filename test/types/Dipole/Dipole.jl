using Unitful, Statistics

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

        b = Neuroimaging.mean(dips)
        @test b.x == 1.0u"m"
        @test b.y == 2.0u"m"
        @test b.z == 2.0u"m"
    end

    @testset "Std" begin

        b = Neuroimaging.std(dips)
        @test b.x == 0.0u"m"
        @test b.y == 0.0u"m"
        @test b.z == Statistics.std([1, 3])u"m"
    end

    @testset "Best" begin

        dip1 = Dipole("Talairach", 1u"mm", 2u"mm", 1u"mm", 0, 0, 0, 1, 1, 1)
        dip2 = Dipole("Talairach", 1u"mm", 2u"mm", 3u"mm", 0, 0, 0, 2, 2, 2)
        dip3 = Dipole("Talairach", 3u"mm", 2u"mm", 3u"mm", 0, 0, 0, 2, 2, 2)
        dip4 = Dipole("Talairach", 3u"mm", 4u"mm", 3u"mm", 0, 0, 0, 2, 2, 2)

        dips = Dipole[]
        dips = push!(dips, dip1)
        dips = push!(dips, dip2)
        dips = push!(dips, dip3)
        dips = push!(dips, dip4)

        # Takes the closest dipole
        bd = best_dipole(dip2, dips)
        @test bd == dip2

        # Takes a larger dipole thats further away if within specified radius
        dip5 = Dipole("Talairach", 1u"mm", 2.01u"mm", 3u"mm", 0, 0, 0, 2, 2, 20)
        dips = push!(dips, dip5)
        bd = best_dipole(dip2, dips)
        @test bd == dip5

        # Reduce radius
        bd = best_dipole(dip2, dips, maxdist = 0.00000001)
        @test bd == dip2

        # Or when nothing of appropriate size
        bd = best_dipole(
            Dipole("Talairach", 10u"mm", 2.01u"mm", 3u"mm", 0, 0, 0, 2, 2, 20),
            dips,
            min_dipole_size = 999,
        )
        @test isnan(bd)

    end
end
