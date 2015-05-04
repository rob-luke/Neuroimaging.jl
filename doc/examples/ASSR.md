## Harmonic Analysis


```julia

using EEG, DataFrames, Gadfly


# Read file and pre processing
a = read_SSR("Example-40Hz.bdf")
a = highpass_filter(a)
a = rereference(a, "Cz")
a = merge_channels(a, EEG_Vanvooren_2014, "Merged")
    remove_channel!(a, EEG_64_10_20)


# Run an F-test and save data
a = extract_epochs(a)
a = create_sweeps(a)
a = ftest(a, modulationrate(a)*[1, 2, 3, 4]) # Look at harmonics
a = ftest(a, [2:200])                        # Look at off stimulation frequencies
a = save_results(a)


# Read the saved data and plot with Gadfly.jl
df = readtable("Example-40Hz.csv")
df[:Significant] = df[:Statistic] .< 0.05

p = plot(df, x="AnalysisFrequency", y="SNRdB", color="Significant",
             xintercept=float(a.modulation_frequency)*[1, 2, 3, 4],
             Geom.vline(color="black"), Geom.point,
             Guide.title("40Hz SSR Highlighting First 4 Harmonics"),
             Guide.xlabel("Frequency (Hz)"), Guide.ylabel("SNR (dB)"),
             Scale.discrete_color_manual("red","green"))

draw(PNG("Example-40Hz.png", 18cm, 12cm), p)
```


Results in the following figure which displays the SNR at each frequency.
The vertical lines highlight the harmonics of the stimulus and color represents if a significant response was detected.

![SSR Example](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/Example-40Hz-SSR.png)
