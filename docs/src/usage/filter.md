# Filtering

Filtering in `Neuroimaging.jl` is performed using the `DSP.jl` backend.

There are two main ways to use the filter function:
1) Modality specific filter
2) Custom defined filter

Let's load some data and apply the filter

```@example filter
using DisplayAs # hide
using Neuroimaging, DataDeps, StatsBase, Unitful

data_path = joinpath(
    datadep"ExampleSSR",
    "Neuroimaging.jl-example-data-master",
    "neuroimaingSSR.bdf",
)

s = read_SSR(data_path)
s.data = s.data .- StatsBase.mean(s.data, dims=1) # remove DC offset for better plotting
```


## 1) Modality specific filter
We offer high and lowpass filter with reasonable defaults for each modality (e.g. `GeneralEEG` a FIR filter,`SSR` a filtfilt Butterworth)

### SSR

```@example filter
using Plots

s_hp = filter_highpass(s, cutOff = 2u"Hz")
s_lp = filter_lowpass(s, cutOff = 5u"Hz") # extreme value to show LP effect in plot

plot(data(s, "F5"), label="raw")
plot!(data(s_hp, "F5"), label="highpass")
plot!(data(s_lp, "F5"), label="lowpass")
current() |> DisplayAs.PNG # hide
```


### EEG

```@example filter
s2 = read_EEG(data_path)
s2.data = s2.data .- StatsBase.mean(s2.data, dims=1) # remove DC offset for better plotting

s_hp = filter_highpass(s2, cutOff = 2u"Hz")
s_lp = filter_lowpass(s2, cutOff = 5u"Hz") # extreme value to show LP effect in plot

plot(data(s2, "F5"), label="raw")
plot!(data(s_hp, "F5"), label="highpass")
plot!(data(s_lp, "F5"), label="lowpass")
current() |> DisplayAs.PNG # hide
```

You can also use a bandpass `filter_bandpass`, which first applys a lowpass and then a highpass. Because data are filtered twice, this takes twice as much time. If you need the speed, we recommend creating your own bandpass and then apply a custom defined filter for now.

## 2) Custom defined filter

Sometimes you want full control over your filter. This can be achieved by defining the filter yourself and leveraging the full power of `DSP.jl`

```@example filter
using DSP
responsetype =  Highpass(3, fs = samplingrate(Float64, s))
designmethod =  Butterworth(6)
zpg = digitalfilter(responsetype, designmethod)

s_custom_filtfilt = Neuroimaging.filtfilt(s, zpg) 

s_custom_filt = Neuroimaging.filt(s, zpg) 

s = trim_channel(s, 10000)
s.data = s.data .- StatsBase.mean(s.data,dims=1) # remove DC offset for better plotting
s_custom_filtfilt = trim_channel(s_custom_filtfilt, 10000)
s_custom_filt = trim_channel(s_custom_filt, 10000)

plot(data(s, "F5"), label="raw")
plot!(data(s_custom_filtfilt, "F5"), label="filtfilt")
plot!(data(s_custom_filt, "F5"), label="filt")
```


## References
Filtering for `GeneralEEG` follows the recommendations of Widmann et al 2014, as implement in the firfilt-eeglab plugin and MNE-Python.
