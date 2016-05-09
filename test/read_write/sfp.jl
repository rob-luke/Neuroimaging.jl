fname = joinpath(dirname(@__FILE__), "..", "data", "test.sfp")

s = read_sfp(fname)

@fact length(s)  --> 3
@fact label(s) --> ["Fp1", "Fpz", "Fp2"]
@fact EEG.x(s) --> [-27.747648, -0.085967, 27.676888]
@fact EEG.y(s) --> [98.803864, 103.555275, 99.133354]
@fact EEG.z(s) --> [34.338360, 34.357265, 34.457005]
@fact typeof(s[1].coordinate) --> EEG.Talairach
