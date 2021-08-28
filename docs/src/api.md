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


## Channels

```@docs
match_sensors
```


## Preprocessing

```@docs
rereference
remove_template
highpass_filter
lowpass_filter
bandpass_filter
compensate_for_filter
epoch_rejection
peak2peak
extract_epochs
```


## Triggers

TODO: Make a type subsection similar to EEG and ASSR.

```@docs
join_triggers
validate_triggers
clean_triggers
```


## Plotting

```@docs
plot_single_channel_timeseries
plot_multi_channel_timeseries
```


## To be sorted

```@docs
find_dipoles
find_location
```
