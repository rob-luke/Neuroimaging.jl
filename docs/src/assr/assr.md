```@docs
SSR
```

## Examples

```julia

using EEG, DataFrames, Gadfly

s = read_SSR("Example-40Hz.bdf")
s = highpass_filter(s)
s.modulationrate = assr_frequency(40)
s = rereference(s, "Cz")
s = merge_channels(s, EEG_Vanvooren_2014, "Merged")
    remove_channel!(s, EEG_64_10_20)
s = extract_epochs(s)
s = create_sweeps(s, epochsPerSweep = 16)
s = ftest(s, collect([[2:2:162], modulationrate(s)*[1, 2, 3, 4]]))

s.processing["statistics"][:Significant] = s.processing["statistics"][:Statistic] .< 0.05
scatter(s.processing["statistics"], 
    :AnalysisFrequency, :SNRdB , group=:Significant,
    xlabel = "Frequency (Hz)", 
    ylabel = "SNR (dB)", 
    xlims = (0, 170), markersize = 10)

vline!(modulationrate(s) * [1 2 3 4], ylims = (-10, 30), linestyle = :dashed)
```

![SSR Example](doc/images/Example-40Hz-SSR.png)


## Functions


A number of functions are provided for the processing of SSR data.


### Preprocessing

```@docs
highpass_filter(::SSR)
```


```@docs
highpass_filter(::SSR, ::AbstractString)
```
