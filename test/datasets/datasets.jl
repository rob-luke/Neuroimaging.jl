# Tests to ensure datasets are available and correct

# Basic biosemi data file
data_path = joinpath(datadep"BioSemiTestFiles", "Newtest17-2048.bdf")
s = read_SSR(data_path)
@test samplingrate(s) == 2048
@test length(channelnames(s)) == 16
@test length(s.triggers["Index"]) == length(s.triggers["Code"])
@test length(s.triggers["Code"]) == ength(s.triggers["Duration"])
