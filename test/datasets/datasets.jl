data_path = joinpath(datadep"BioSemiTestFiles", "Newtest17-2048.bdf")
s = read_SSR(data_path)

@test samplerate(s) == 200