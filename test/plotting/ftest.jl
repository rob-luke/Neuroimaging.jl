#=fname = "/Users/rluke/Data/EEG/BDFs/NH/example/Example-40Hz.bdf"=#

fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)

s.modulationrate = 40.0390625

plot_ftest(s, epochsPerSweep = 4)

println()
println("!! F test plotting passed !!")
println()
