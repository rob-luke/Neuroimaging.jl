fname = joinpath(dirname(@__FILE__), "../data", "test.bsa")

dips = read_bsa(fname)

@test size(dips) == (2,)
