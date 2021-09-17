# Filtering

Filtering in `Neuroimaging.jl` is performed using the `DSP.jl` backend.

There are two main ways to use the filter function:
1) Modality specific filter
2) Custom defined filter

Let's load some data and apply the filter

```@example filter
using DisplayAs # hide
using Neuroimaging, DataDeps, StatsBase

data_path = joinpath(
    datadep"ExampleSSR",
    "Neuroimaging.jl-example-data-master",
    "neuroimaingSSR.bdf",
)

s = read_EEG(data_path)
s.data = s.data .- StatsBase.mean(s.data,dims=1) # remove DC offset for better plotting
```


## 1) Modality specific filter
We offer high and lowpass filter with reasonable defaults for each modality (e.g. `GeneralEEG` a FIR filter,`SSR` a filtfilt Butterworth)

```@example filter
s_hp = filter_highpass(s,2)
s_lp = filter_lowpass(s,5) # extreme value to show LP effect in plot

plot(s.data[:,1],label="raw")
plot!(s_hp.data[:,1],label="highpass")
plot!(s_lp.data[:,1],label="lowpass")
```

You can also use a bandpass `filter_bandpass`, which first applys a lowpass and then a highpass. Because data are filtered twice, this takes twice as much time. If you need the speed, we recommend creating your own bandpass and then apply a custom defined filter for now.

## 2) Custom defined filter
Sometimes you want full control over your filter. This can be achieved by defining the filter yourself and leveraging the full power of `DSP.jl`
```@example filter
using DSP
responsetype =  Highpass(3,fs=s.fs)
designmethod =  Butterworth(6)

#filtfilt needs to be `true` to compensate for non-linear phase response of butterworth
s_custom = filter(s,responsetype,designmethod,filtfilt=true) 

plot(s.data[:,1],label="raw")
plot!(s_custom.data[:,1],label="custom highpass")
```


## References
Filtering for `GeneralEEG` follows the recommendations of Widmann et al 2014, as implement in the firfilt-eeglab plugin and MNE-Python.

Filtering for `SSR` follows the recommendations of Rob-Luke TODO