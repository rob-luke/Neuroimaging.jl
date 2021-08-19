# Tests to ensure datasets are available and correct

# Basic biosemi data file
data_path = joinpath(datadep"BioSemiTestFiles", "Newtest17-2048.bdf")
s = read_SSR(data_path)
@test samplerate(s) == 2048
@test length(channelnames(s)) == 16
@test length(s.triggers["Index"])
@test length(s.triggers["Code"])
@test length(s.triggers["Duration"])