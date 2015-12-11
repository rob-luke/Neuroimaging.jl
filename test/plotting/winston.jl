fname = joinpath(dirname(@__FILE__), "../data", "test-3d.dat")

x, y, z, s, t = read_dat(fname)

p = plot_dat(squeeze(s, 4))

elec = Electrodes("Cartesian", "EEG", ["elec1", "elec2"], [3.0, 2.0], [3.0, 2.0], [3.0, 2.0])

oplot(p, elec)


#
# Spectrogram
#

fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)

p = SSR_spectrogram(s, "20Hz_SWN_70dB_R", 1.0, 50.0, seconds = 2)



#
# Plot spectrum
#

s = extract_epochs(s)
s = create_sweeps(s, epochsPerSweep = 2)
s = ftest(s)

p = plot_spectrum(s, "20Hz_SWN_70dB_R", targetFreq = 3.0)
p = plot_spectrum(vec(s.data[:, 1]), Int(samplingrate(s)), dBPlot = false)


#
# Plot filter
#

s = highpass_filter(s)
p = plot_filter_response(s.processing["filter1"], Int(samplingrate(s)))
