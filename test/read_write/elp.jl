e = read_elp(joinpath(dirname(@__FILE__), "..", "data", "test.elp"))

@test length(e.x) == 2
@test e.label[1] == "Fpz"
@test e.label[2] == "Fp2"
