fname = joinpath(dirname(@__FILE__), "../data", "test-3d.dat")

x, y, z, s, t = read_dat(fname)

p = plot_dat(squeeze(s, 4))


#
# Spectrogram
#

fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)

p = SSR_spectrogram(s, "20Hz_SWN_70dB_R", 1.0, 50.0, seconds = 2)


#
# Plot spectrum
#

p = plot_spectrum(s, "20Hz_SWN_70dB_R")
