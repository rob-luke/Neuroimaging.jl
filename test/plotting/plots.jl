unicodeplots()
#= gadfly() =#

fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)

s = extract_epochs(s)
s = create_sweeps(s, epochsPerSweep = 2)
s = ftest(s)

p = plot_spectrum(s, "20Hz_SWN_70dB_R", targetFreq = 3.0)
display(p)

p = plot_spectrum(vec(s.data[:, 1]), Int(samplingrate(s)), dBPlot = false)
display(p)

p = plot_spectrum(s, 3, targetFreq = 40.0390625)
display(p)

