# Library

---

```@meta
CurrentModule = EEG
```

## Module
```@docs
EEG
```

## To be sorted

```@docs
remove_template
import_biosemi 
add_channel
join_triggers
keep_channel!
validate_triggers
clean_triggers
remove_channel!
samplingrate
Dipole
extract_epochs
VolumeImage
find_dipoles
find_location
```

## IO

```@docs
read_elp
write_avr
read_avr
read_evt
read_sfp
read_dat
read_bsa
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

## Statistics

```@docs
ftest
```

## Plotting

```@docs
plot_single_channel_timeseries
plot_multi_channel_timeseries
```
