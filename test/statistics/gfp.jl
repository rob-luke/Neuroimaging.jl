@testset "Statistics" begin

    fname = joinpath(dirname(@__FILE__), "..", "data", "test_Hz19.5-testing.bdf")

    s = read_SSR(fname)

    @testset "Global Field Power" begin

        ~ = gfp(s.data)  # TODO: Check result
    end
end




