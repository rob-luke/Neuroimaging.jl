using EEGjl
using Winston

fname = "../data/Example-40Hz.bdf"

s = read_SSR(fname, verbose=true)

s = proc_hp(s, cutOff=2, verbose=true)

    p = plot_filter_response(s.processing["filter1"], 8192)
    file(p, "Eg1-Filter.png", width=1200, height=800)

s = proc_reference(s, "average", verbose=true)

    p = plot_timeseries(s, "Cz")
    file(p, "Eg1-RawData.png", width=1200, height=600)

    p = plot_timeseries(s)
    file(p, "Eg1-AllChannels.png", width=1200, height=800)

s = extract_epochs(s, verbose=true)

s = create_sweeps(s, epochsPerSweep=32, verbose=true)

s = ftest(s, 40.0391, verbose=true)
s = ftest(s, 41.0391, verbose=true)

    p = plot_spectrum(s, "T8", targetFreq=40.0391)
    file(p, "Eg1-SweepSpectrum-T8.png", width=1200, height=800)

s = save_results(s, name_extension="-ftest-", verbose=true)
