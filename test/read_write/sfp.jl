fname = joinpath(dirname(@__FILE__), "..", "data", "test.sfp")

s = read_sfp(fname)

@test length(s) == 3
@test label(s) == ["Fp1", "Fpz", "Fp2"]
println(Neuroimaging.x(s))
@test Neuroimaging.x(s) == [-27.747648 * u"m", -0.085967 * u"m", 27.676888 * u"m"]
@test Neuroimaging.y(s) == [98.803864 * u"m", 103.555275 * u"m", 99.133354 * u"m"]
@test Neuroimaging.z(s) == [34.338360 * u"m", 34.357265 * u"m", 34.457005 * u"m"]
@test typeof(s[1].coordinate) == Neuroimaging.Talairach
