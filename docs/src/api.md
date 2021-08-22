# Low-Level Function API

As well as providing convenient types for analysis.
This package also provides low-level functions for dealing with
data in its raw form.
These low-level functions are described below.

Note: Currently sorting out the docs, so its a bit of a mess.
Is there an automated way to list all functions using documenter?

---

```@meta
CurrentModule = Neuroimaging
```

## Module
```@docs
Neuroimaging
```

## To be sorted

```@docs
remove_template
add_channel
join_triggers
keep_channel!
validate_triggers
clean_triggers
remove_channel!
samplingrate
extract_epochs
find_dipoles
find_location
```


## Channels

```@docs
match_sensors
trim_channel
channelnames
merge_channels
channel_rejection
```

## Preprocessing

```@docs
rereference
highpass_filter
lowpass_filter
bandpass_filter
compensate_for_filter
epoch_rejection
peak2peak
```


## Plotting

```@docs
plot_single_channel_timeseries
plot_multi_channel_timeseries
```
