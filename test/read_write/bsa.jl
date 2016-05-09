fname = joinpath(dirname(@__FILE__), "../data", "test.bsa")

dips = read_bsa(fname)

@fact size(dips) --> (2,)
