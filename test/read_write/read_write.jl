@testset "File formats" begin

    @testset "avr" begin
        include("avr.jl")
    end
    @testset "bsa" begin
        include("bsa.jl")
    end
    @testset "dat" begin
        include("dat.jl")
    end
    @testset "elp" begin
        include("elp.jl")
    end
    @testset "evt" begin
        include("evt.jl")
    end
    @testset "rba" begin
        include("rba.jl")
    end
    @testset "sfp" begin
        include("rba.jl")
    end
end

