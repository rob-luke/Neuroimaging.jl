e = read_elp(joinpath(dirname(@__FILE__), "..", "data", "test.elp"))

@fact length(e) --> 2
@fact e[1].label --> "Fpz"
@fact e[2].label --> "Fp2"
