## Plot F-test spectrum

```julia
using EEG

s = read_SSR("file.bdf")
s = highpass_filter(s)
s = rereference(s, "Cz")
s = merge_channels(s, EEG_Vanvooren_2014, "Merged")
    remove_channel!(s, EEG_64_10_20)
s = extract_epochs(s)
s = create_sweeps(s, epochsPerSweep = 8)
s = ftest(s)

plot_spectrum(s, "Merged")
```

![Ftest](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/ftest.png)
