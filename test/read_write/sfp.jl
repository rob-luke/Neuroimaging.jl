fname = joinpath(dirname(@__FILE__), "..", "data", "test.sfp")

s = read_sfp(fname)

@test length(s)  == 3
@test label(s) == ["Fp1", "Fpz", "Fp2"]
@test EEG.x(s) == [-27.747648, -0.085967, 27.676888]
@test EEG.y(s) == [98.803864, 103.555275, 99.133354]
@test EEG.z(s) == [34.338360, 34.357265, 34.457005]
@test typeof(s[1].coordinate) == EEG.Talairach
