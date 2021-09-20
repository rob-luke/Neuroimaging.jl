"""
Abstract type for storing Neuroimaing data.

All other neuroimaging types inherit from this type.
All neuroimaing types support the following functions:

* `samplingrate()`
* `channelnames()`
* `remove_channel!()`
* `keep_channel!()`
* `trim_channel()`
* `highpass_filter()`
* `lowpass_filter()`
* `data()`

# Examples
```julia
data = # load your neuroimaging data
samplingrate(data)  # Returns the sampling rate
channelnames(data)  # Returns the channel names
```
"""
abstract type NeuroimagingMeasurement end
