using Neuroimaging, DataDeps, Test
# Tests to ensure datasets are available and correct

# Basic biosemi data file
data_path = joinpath(datadep"BioSemiTestFiles", "Newtest17-2048.bdf")
s = read_SSR(data_path)
@test samplingrate(s) == 2048u"Hz"
@test length(channelnames(s)) == 16
@test length(s.triggers["Index"]) == length(s.triggers["Code"])
@test length(s.triggers["Code"]) == length(s.triggers["Duration"])


# Basic biosemi data file
data_path = joinpath(
    datadep"ExampleSSR",
    "Neuroimaging.jl-example-data-master",
    "neuroimaingSSR.bdf",
)
s = read_SSR(data_path)
@test samplingrate(s) == 8192u"Hz"
@test length(channelnames(s)) == 7
@test length(s.triggers["Index"]) == length(s.triggers["Code"])
@test length(s.triggers["Code"]) == length(s.triggers["Duration"])
