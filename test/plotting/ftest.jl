using EEG
using Base.Test
using Logging

Logging.configure(level=DEBUG)

fname = "/Users/rluke/Data/EEG/BDFs/NH/single-channel/JefMombaerts-20Hz-R.bdf"

s = read_SSR(fname)

s = extract_epochs(s)

s = create_sweeps(s, epochsPerSweep=16)

spectrum    = EEG._ftest_spectrum(s.processing["sweeps"])
spectrum    = compensate_for_filter(s.processing, spectrum, float(s.sample_rate))
frequencies = linspace(0, 1, int(size(spectrum, 1)))*float(s.sample_rate)/2

plot_ftest(spectrum, frequencies, float(s.modulation_frequency), 1, 2, max_plot_freq=90)
