# Functions

In addition to the function available for processing EEG data,
a number of functions are provided specifically for the processing of SSR data


## Import

```@docs
read_EEG
```


## Querying data

```@docs
samplingrate(::EEG)
channelnames(::EEG)
```


## Manipulating data

```@docs
hcat(::EEG, ::EEG)
add_channel(::EEG, ::Vector, ::AbstractString)
remove_channel!(::EEG, ::AbstractString)
keep_channel!(::EEG, ::AbstractString)
trim_channel(::EEG, ::Int)
merge_channels
channel_rejection
```


## Plotting

```@docs
plot_timeseries(::EEG)
```
