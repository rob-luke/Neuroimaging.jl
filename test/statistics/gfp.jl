fname = joinpath(dirname(@__FILE__), "..", "data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)

~ = gfp(s.data)  # TODO: Check result

