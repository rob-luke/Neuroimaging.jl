facts("Statistics") do

    fname = joinpath(dirname(@__FILE__), "..", "data", "test_Hz19.5-testing.bdf")

    s = read_SSR(fname)

    context("Global Field Power") do

        ~ = gfp(s.data)  # TODO: Check result
    end
end




