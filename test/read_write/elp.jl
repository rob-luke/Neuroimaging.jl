e = read_elp(joinpath(dirname(@__FILE__), "..", "data", "test.elp"))

@test length(e) == 2
@test e[1].label == "Fpz"
@test e[2].label == "Fp2"
