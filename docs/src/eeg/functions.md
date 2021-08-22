# Functions

In addition to the function available for processing EEG data,
a number of functions are provided specifically for the processing of SSR data


## Import

```@docs
read_EEG
```

## General


```@docs
samplingrate(::EEG)
channelnames(::EEG)
hcat(::EEG, ::EEG)
add_channel(::EEG, ::Vector, ::AbstractString)
remove_channel!(::EEG, ::AbstractString)
keep_channel!(::EEG, ::AbstractString)
trim_channel(::EEG, ::Int)
keep_channel!(::EEG, ::AbstractString)
```


## Plotting

```@docs
plot_timeseries(::EEG)
```


