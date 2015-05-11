## Exported
---

### _find_closest_number_idx{T<:Number}(list::Array{T<:Number, 1}, target::Number)
Find the closest number to a target in an array and return the index

### Arguments

* `list`: Array containing numbers
* `target`: Number to find closest to in the list

### Output

* Index of the closest number to the target

### Returns

```julia
_find_closest_number_idx([1, 2, 2.7, 3.2, 4, 3.1, 7], 3)

# 6
```


*source:*
[EEG/src/miscellaneous/helper.jl:151](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/miscellaneous/helper.jl#L151)

---

### add_channel(a::SSR, data::Array{T, N}, chanLabels::ASCIIString)
Add a channel to the SSR type with specified channel names.

### Example

Add a channel called `Merged`

```julia
s = read_SSR(filename)
new_channel = mean(s.data, 2)
s = add_channel(s, new_channel, "Merged")
```


*source:*
[EEG/src/types/SSR/SSR.jl:132](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/SSR.jl#L132)

---

### append_strings(strings::Union(Array{ASCIIString, N}, Array{String, N}))
Concatanate `strings` with a `separator` between each.

### Arguments

* `strings`: Array of strings to place one after another
* `separator`: String to place between each string (Default: ` `)

### Output

String consisting of all input strings


*source:*
[EEG/src/miscellaneous/helper.jl:12](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/miscellaneous/helper.jl#L12)

---

### bandpass_filter(signals::Array{T, N}, lower::Number, upper::Number, fs::Number, n::Int64, rp::Number)
Band pass filter


*source:*
[EEG/src/preprocessing/filtering.jl:68](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/filtering.jl#L68)

---

### best_dipole(ref::Union(Dipole, Coordinate), dips::Array{Dipole, N})
Find best dipole relative to reference location.

Finds the largest dipole within a specified distance of a reference location

### Input

* ref: Reference coordinate or dipole
* dips: Dipoles to find the best dipole from
* maxdist: Maximum distance a dipole can be from the reference

### Output

* dip: The best dipole



*source:*
[EEG/src/source_analysis/dipoles.jl:141](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/source_analysis/dipoles.jl#L141)

---

### bootstrap(s::SSR)
Estimate the value and standard deviation of ASSR response amplitude and phase using bootstrapping on the frequency
bin across epochs.

### Input

* `s`: Steady state response type
* `freq_of_interest`: frequency to analyse (modulation rate)
* `ID`: value to store as ID (" ")
* `data_type`: what to run the fft on (epochs)
* `fs`: sampling rate (SSR sampling rate)
* `num_resample`: number of bootstrapping interations to make (1000)
* `results_key`: Where in the processing dictionary to store results ("statistics")

### Output

* Bootstrapping values are added to the processing key `statistics`

### Example

```julia
s = bootstrap(s, N=100)
```


*source:*
[EEG/src/types/SSR/Statistics.jl:31](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/Statistics.jl#L31)

---

### channel_rejection{T<:Number}(sigs::Array{T<:Number, N}, threshold_abs::Number, threshold_var::Number)
Reject channels with too great a variance.

Rejection can be based on a threshold or dynamicly chosen based on the variation of all channels.

### Arguments

* `signals`: Array of data in format samples x channels
* `threshold_abs`: Absolute threshold to remove channels with variance above this value
* `threshold_std`: Reject channels with a variance more than n times the std of all channels

### Returns

An array indicating the channels to be kept


*source:*
[EEG/src/preprocessing/data_rejection.jl:61](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/data_rejection.jl#L61)

---

### clean_triggers(t::Dict{K, V}, valid_triggers::Array{Int64, N}, min_epoch_length::Int64, max_epoch_length::Number, remove_first::Int64, max_epochs::Number)
Clean trigger channel


*source:*
[EEG/src/preprocessing/triggers.jl:39](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/triggers.jl#L39)

---

### compensate_for_filter(filter::FilterCoefficients, spectrum::AbstractArray{T, N}, frequencies::AbstractArray{T, N}, fs::Real)
Recover the spectrum of signal by compensating for filtering done.

### Arguments

* `filter`: The filter used on the spectrum
* `spectrum`: Spectrum of signal
* `frequencies`: Array of frequencies you want to apply the compensation to
* `fs`: Sampling rate

### Returns

Spectrum of the signal after comensating for the filter

### TODO

Extend this to arbitrary number of dimensions rather than the hard coded 3


*source:*
[EEG/src/preprocessing/filtering.jl:132](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/filtering.jl#L132)

---

### epoch_rejection{T<:Number}(epochs::Array{T<:Number, 3}, retain_percentage::FloatingPoint)
Reject epochs based on the maximum peak to peak voltage within an epoch across all channels

### Arguments

* `epochs`: Array containing the epoch data in the format samples x epochs x channels
* `retain_percentage`: The percentage of epochs to retain
* `rejection_method`: Method to be used for epoch rejection (peak2peak)

### Returns

* An array with a reduced amount of entries in the epochs dimension


*source:*
[EEG/src/preprocessing/data_rejection.jl:13](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/data_rejection.jl#L13)

---

### extra_triggers(t::Dict{K, V}, old_trigger_code::Union(Int64, Array{Int64, N}), new_trigger_code::Int64, new_trigger_time::Number, fs::Number)
Place extra triggers a set time after existing triggers.

A new trigger with `new_trigger_code` will be placed `new_trigger_time` seconds after exisiting `old_trigger_code` triggers.


*source:*
[EEG/src/preprocessing/triggers.jl:131](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/triggers.jl#L131)

---

### extract_epochs(a::SSR)
## Extract epoch data from SSR

### Arguments
* `a`: A SSR object
* `valid_triggers`: Trigger numbers that are considered valid ([1,2])
* `remove_first`: Remove the first n triggers (0)
* `remove_last`: Remove the last n triggers (0)

### Example

```julia
epochs = extract_epochs(SSR, valid_triggers=[1,2])
```


*source:*
[EEG/src/types/SSR/Reshaping.jl:15](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/Reshaping.jl#L15)

---

### extract_epochs(data::Array{T, N}, triggers::Dict{K, V}, valid_triggers::AbstractArray{T, 1}, remove_first::Int64, remove_last::Int64)
Extract epoch data from array of channels.

### Input

* Array of raw data. Samples x Channels
* Dictionary of trigger information
* Vector of valid trigger numbers
* Number of first triggers to remove
* Number of end triggers to remove

### Example

```julia
epochs = extract_epochs(data, triggers, [1,2], 0, 0)
```


*source:*
[EEG/src/reshaping/epochs.jl:24](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/reshaping/epochs.jl#L24)

---

### fileparts(fname::String)
Extract the path, filename and extension of a file

### Arguments

* `fname`: String with the full path to a file

### Output

* Three strings containing the path, file name and file extension

### Returns

```julia
fileparts("/Users/test/subdir/test-file.bdf")

# ("/Users/test/subdir/","test-file","bdf")
```


*source:*
[EEG/src/miscellaneous/helper.jl:114](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/miscellaneous/helper.jl#L114)

---

### find_dipoles{T<:Number}(s::Array{T<:Number, 3})
Find all dipole in an activity map.

Determines the local maxima in a 3 dimensional array

### Input

* s: Activity in 3d matrix
* window: Windowing to use in each dimension for min max filter
* x,y,z: Coordinates associated with s matrix

### Output

* dips: An array of dipoles



*source:*
[EEG/src/source_analysis/dipoles.jl:59](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/source_analysis/dipoles.jl#L59)

---

### find_keys_containing(d::Dict{K, V}, partial_key::String)
Find dictionary keys containing a string.

### Arguments

* `d`: Dictionary containing existing keys
* `partial_key`: String you want to find in key names

### Returns

* Array containg the indices of dictionary containing the partial_key

### Returns

```julia
results_storage = Dict()
results_storage[new_processing_key(results_storage, "FTest")] = 4
results_storage[new_processing_key(results_storage, "Turtle")] = 5
results_storage[new_processing_key(results_storage, "FTest")] = 49

find_keys_containing(results_storage, "FTest")

# 2-element Array{Int64,1}:
#  1
#  3
```


*source:*
[EEG/src/miscellaneous/helper.jl:89](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/miscellaneous/helper.jl#L89)

---

### ftest(sweeps::Union(Array{Float32, 3}, Array{Float64, 3}), freq_of_interest::Real, fs::Real, side_freq::Real, used_filter::Union(Filter{I}, Nothing), spill_bins::Int64)
Calculates the F test as is commonly implemented in SSR research.  
TODO: Add references to MASTER and Luts et al

### Parameters

* Sweep measurements. Samples x Sweeps x Channels
* Frequency(ies) of interest (Hz)
* Sampling rate (Hz)
* The amount of data to use on each side of frequency of interest to estimate noise (Hz)
* Filter used on the sweep data. If provided then is compensated for
* The number of bins to ignore on each side of the frequency of interest

### Returns

* Signal to noise ratio in dB
* Signal phase at frequency of interest
* Signal power at frequency of interest
* Noise power estimated of side frequencies
* F statistic



*source:*
[EEG/src/statistics/ftest.jl:22](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/statistics/ftest.jl#L22)

---

### highpass_filter{T<:FloatingPoint}(signals::Array{T<:FloatingPoint, N}, cutOff::Number, fs::Number, order::Int64)
High pass filter applied in forward and reverse direction

Simply a wrapper for the DSP.jl functions

### Arguments

* `signals`: Signal data in the format samples x channels
* `cutOff`: Cut off frequency in Hz
* `fs`: Sampling rate
* `order`: Filter orde

### Returns

* filtered signal
* filter used on signal


*source:*
[EEG/src/preprocessing/filtering.jl:17](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/filtering.jl#L17)

---

### import_biosemi(fname::Union(IO, String))
Import Biosemi files


*source:*
[EEG/src/read_write/bdf.jl:9](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/read_write/bdf.jl#L9)

---

### keep_channel!(a::SSR, channel_names::Array{ASCIIString, N})
Remove all channels except those requested from SSR.

### Example

Remove all channels except Cz and those in the set called `EEG_Vanvooren_2014_Right`

```julia
a = read_SSR(filename)
keep_channel!(a, [EEG_Vanvooren_2014_Right, "Cz"])
```


*source:*
[EEG/src/types/SSR/SSR.jl:198](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/SSR.jl#L198)

---

### lowpass_filter{T<:FloatingPoint}(signals::Array{T<:FloatingPoint, N}, cutOff::Number, fs::Number, order::Int64)
Low pass filter applied in forward and reverse direction

Simply a wrapper for the DSP.jl functions

### Input

* `signals`: Signal data in the format samples x channels
* `cutOff`: Cut off frequency in Hz
* `fs`: Sampling rate
* `order`: Filter orde

### Output

* filtered signal
* filter used on signal


*source:*
[EEG/src/preprocessing/filtering.jl:50](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/filtering.jl#L50)

---

### merge_channels(a::SSR, merge_Chans::Array{ASCIIString, N}, new_name::String)
Merge `SSR` channels listed in `merge_Chans` and label the averaged channel as `new_name`

### Example

```julia
s = merge_channels(s, ["P6", "P8"], "P68")
```


*source:*
[EEG/src/types/SSR/SSR.jl:275](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/SSR.jl#L275)

---

### modulationrate(t, s::SSR)
Return the modulation rate of a steady state type.
If no type is provided, the modulation rate is returned as a floating point.

### Example

Return the modulation rate of a recording

```julia
s = read_SSR(filename)
modulationrate(s)
```


*source:*
[EEG/src/types/SSR/SSR.jl:81](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/SSR.jl#L81)

---

### new_processing_key(d::Dict{K, V}, key_name::String)
Return a new processing key with the number incremented.
It checks for existing keys and returns a string with the next key to be used.

### Arguments

* `d`: Dictionary containing existing keys
* `key_name`: Base of the

### Returns

* String with new key name

### Returns

```julia
results_storage = Dict()
results_storage[new_processing_key(results_storage, "FTest")] = 4
results_storage[new_processing_key(results_storage, "FTest")] = 49

# Dict(Any, Any) with 2 entries
#   "FTest1" => 4
#   "FTest2" => 49
```


*source:*
[EEG/src/miscellaneous/helper.jl:51](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/miscellaneous/helper.jl#L51)

---

### phase_lag_index(a::SSR, ChannelOrigin::Int64, ChannelDestination::Int64, freq_of_interest::Real)
## Phase Lag Index

Calculate phase lag index between SSR sensors.

This is a wrapper function for the SSR type.
The calculation of PLI is calculated using [Synchrony.jl](www.github.com/.....)


*source:*
[EEG/src/types/SSR/Synchrony.jl:14](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/Synchrony.jl#L14)

---

### phase_lag_index(data::Array{T, N}, freq_of_interest::Real, fs::Real)
Phase locked index of waveforms two time series cut in to epochs.

Calculated using [Synchrony.jl](https://github.com/simonster/Synchrony.jl)

### Arguments

* `data`: samples x channels x epochs as described in [multitaper documentation](https://github.com/simonster/Synchrony.jl/blob/master/src/multitaper.jl)
* `freqrange`: range of frequencies to analyse
* `fs`: sample rate


*source:*
[EEG/src/synchrony/phase_lag_index.jl:11](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/synchrony/phase_lag_index.jl#L11)

---

### plot_dat{T<:Number}(x::Array{T<:Number, 1}, y::Array{T<:Number, 1}, z::Array{T<:Number, 1}, dat_data::Array{T<:Number, N})
Plot a dat file from three views.

### Optional Arguments

* threshold_ratio(1/1000): locations smaller than this are not plotted
* ncols(2): number of colums used for output plot
* max_size(2): maximum size for any point



*source:*
[EEG/src/plotting/winston.jl:16](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/plotting/winston.jl#L16)

---

### plot_ftest(s::SSR)
Visualise the data used to determine the f statistic.

The spectrum is plotted in black, the noise estimate is highlited in red, and the signal marked in green.
Dots indicate the noise and signal power.

This wrapper function extracts all required information from the SSR type

### Input

* s: Steady state response type

### Output

Saves a pdf to disk


*source:*
[EEG/src/plotting/plot.jl:24](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/plotting/plot.jl#L24)

---

### plot_ftest{T<:FloatingPoint}(spectrum::Array{Complex{T<:FloatingPoint}, 2}, frequencies::AbstractArray{T, N}, freq_of_interest::Real, side_freq::Real, spill_bins::Int64, min_plot_freq::Real, max_plot_freq::Real, plot_channel::Int64)
Visualise the data used to determine the f statistic.

The spectrum is plotted in black, the noise estimate is highlited in red, and the signal marked in green.
Dots indicate the noise and signal power.

### Input

* spectrum: Spectrum of data to plot
* frequencies: The frequencies associated with each point in the spectrum
* freq_of_interest: The frequency to analyse
* side_freq: How many Hz each side to use to determine the noise estimate
* spill_bins: How many bins either side of the freq_of_interest to ignore in noise estimate. This is in case of spectral leakage
* min_plot_freq: Minimum frequency to plot in Hz
* max_plot_freq: Maximum frequency to plot in Hz
* plot_channel: If there are multiple dimensions, this specifies which to plot

### Output

Saves a pdf to disk


*source:*
[EEG/src/plotting/plot.jl:81](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/plotting/plot.jl#L81)

---

### plot_multi_channel_timeseries{T<:Number}(signals::Array{T<:Number, 2}, fs::Number, channels::Array{ASCIIString, N})
Plot a multi channel time series

### Input

* signals: Array of data
* fs: Sample rate
* channels: Name of channels
* plot_points: Number of points to plot, they will be equally spread. Used to speed up plotting
* Other optional arguements are passed to gadfly plot function


### Output

Returns a figure



*source:*
[EEG/src/plotting/plot.jl:177](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/plotting/plot.jl#L177)

---

### plot_single_channel_timeseries{T<:Number}(signal::AbstractArray{T<:Number, 1}, fs::Number)
Plot a single channel time series

### Input

* signal: Vector of data
* fs: Sample rate
* channels: Name of channel to plot
* plot_points: Number of points to plot, they will be equally spread. Used to speed up plotting
* Other optional arguements are passed to gadfly plot function


### Output

Returns a figure



*source:*
[EEG/src/plotting/plot.jl:146](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/plotting/plot.jl#L146)

---

### plot_timeseries(s::SSR)
Plot an SSR recording.

Plot detailed single channel or general multichanel figure depending on how many channels are requested.

### Input

* s: SSR type
* channels: The channels you want to plot, all if not specified
* fs: Sample rate
* Other optional arguements are passed to gadfly plot function


### Output

Returns a figure


### Example

plot1 = plot_timeseries(s, channels=["P6", "Cz"], plot_points=8192*4)
draw(PDF("timeseries.pdf", 10inch, 6inch), plot1)




*source:*
[EEG/src/types/SSR/plotting.jl:25](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/plotting.jl#L25)

---

### prepare_dat(d::Array{T, 1}, x::Array{T, 1}, y::Array{T, 1}, z::Array{T, 1})
Convert vector format source results to 3d array used in dat files

### Example:
```julia
x, y, z, s = prepare_dat(d, x, y, z)
```


*source:*
[EEG/src/read_write/dat.jl:140](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/read_write/dat.jl#L140)

---

### read_SSR(fname::String)
## Read SSR from file or IO stream
Read a file or IO stream and store the data in an `SSR` type.

Matching .mat files are read and modulation frequency information extracted.
Failing that, user passed arguments are used or the modulation frequency is extracted from the file name.

### Arguments

* `fname`: Name of the file to be read
* `min_epoch_length`: Minimum epoch length in samples. Shorter epochs will be removed (0)
* `max_epoch_length`: Maximum epoch length in samples. Longer epochs will be removed (Inf)
* `valid_triggers`: Triggers that are considered valid, others are removed ([1,2])
* `stimulation_amplitude`: Amplitude of stimulation (NaN)
* `modulationrate`: Modulation frequency of SSR stimulation (NaN)
* `carrier_frequency`: Carrier frequency (NaN)
* `participant_name`: Name of participant ("")
* `remove_first`: Number of epochs to be removed from start of recording (0)
* `max_epochs`: Maximum number of epochs to retain (Inf)
* `env` (nothing)
* `bkt` ("")

### Supported file formats

* BIOSEMI (.bdf)


*source:*
[EEG/src/types/SSR/ReadWrite.jl:32](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/ReadWrite.jl#L32)

---

### read_avr(fname::String)
Read AVR (.avr) file

### Input
* `fname`: Name or path for the AVR file

### Output
* `data`: Array of data read from AVR file. Each column represents a channel, and each row represents a point.
* `chanNames`: Channel Names



*source:*
[EEG/src/read_write/avr.jl:17](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/read_write/avr.jl#L17)

---

### read_bsa(fname::String)
Read Besa's BSA (.bsa) file

### Input
* `fname`: Name or path for the BSA file

### Output
* `bsa`: Dipole object


*source:*
[EEG/src/read_write/bsa.jl:15](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/read_write/bsa.jl#L15)

---

### read_dat(fname::String)
Read dat files

### Arguments
* `fname`: Name or path for the dat file

### Returns
* `x`: Range of x values
* `y`: Range of y values
* `z`: Range of z values
* `complete_data`: Array (x × y × z x t)
* `sample_times`

### References
File specs were taken from [fieldtrip](https://github.com/fieldtrip/fieldtrip/blob/1cabb512c46cc70e5b734776f20cdc3c181243bd/external/besa/readBESAimage.m)


*source:*
[EEG/src/read_write/dat.jl:22](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/read_write/dat.jl#L22)

---

### read_evt(fname::String, fs::Number)
Read *.evt file and convert to form for EEG.jl


*source:*
[EEG/src/read_write/evt.jl:9](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/read_write/evt.jl#L9)

---

### read_rba_mat(mat_path)
Read rba from MAT file


*source:*
[EEG/src/read_write/rba.jl:9](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/read_write/rba.jl#L9)

---

### read_sfp(fname::String)
Read sfp file

### Input
* `fname`: Name or path for the sfp file

### Output
* `elec`: Electrodes object


*source:*
[EEG/src/read_write/sfp.jl:15](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/read_write/sfp.jl#L15)

---

### remove_channel!(a::SSR, channel_names::Array{ASCIIString, N})
Remove specified channels from SSR.

### Example

Remove channel Cz and those in the set called `EEG_Vanvooren_2014_Right`

```julia
a = read_SSR(filename)
remove_channel!(a, [EEG_Vanvooren_2014_Right, "Cz"])
```


*source:*
[EEG/src/types/SSR/SSR.jl:155](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/SSR.jl#L155)

---

### remove_template{T<:FloatingPoint}(signals::Array{T<:FloatingPoint, 2}, template::Array{T<:FloatingPoint, 1})
Remove a template signal from each column of an array

### Arguments

* `signals`: Original signals to be modified
* `template`: Template to remove from each signal

### Returns
Signals with template removed


*source:*
[EEG/src/preprocessing/reference.jl:11](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/reference.jl#L11)

---

### rereference{S<:String, T<:FloatingPoint}(signals::Array{T<:FloatingPoint, 2}, refChan::Union(S<:String, Array{S<:String, N}), chanNames::Array{S<:String, N})
Re-reference a signals to specific signal channel by name.

If multiple channels are specififed, their average is used as the reference.
Or you can specify to use the `average` reference.

### Arguments

* `signals`: Original signals to be modified
* `refChan`: List of channels to be used as reference or `average`
* `chanNames`: List of channel names associated with signals array

### Returns

Rereferenced signals


*source:*
[EEG/src/preprocessing/reference.jl:70](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/reference.jl#L70)

---

### rereference{T<:FloatingPoint}(signals::Array{T<:FloatingPoint, 2}, refChan::Union(Int64, Array{Int64, N}))
Re reference a signals to specific signal channel by index.

If multiple channels are specififed, their average is used as the reference.

### Arguments

* `signals`: Original signals to be modified
* `refChan`: Index of channels to be used as reference

### Returns

Rereferenced signals


*source:*
[EEG/src/preprocessing/reference.jl:38](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/reference.jl#L38)

---

### samplingrate(t, s::SSR)
Return the sampling rate of a steady state type.
If no type is provided, the sampling rate is returned as a floating point.

### Example

Return the sampling rate of a recording

```julia
s = read_SSR(filename)
samplingrate(s)
```


*source:*
[EEG/src/types/SSR/SSR.jl:64](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/SSR.jl#L64)

---

### save_synchrony_results(a::SSR)
Save synchrony results to file

### Arguments
* `a`: A SSR object
* `name_extension`: string appended at the end of the saved file name

### Returns
The same object `a`


*source:*
[EEG/src/types/SSR/Synchrony.jl:120](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/Synchrony.jl#L120)

---

### trim_channel(a::SSR, stop::Int64)
Trim SSR recording by removing data after `stop` specifed samples.

### Optional Parameters

* `start` Remove samples before this value

### Example

Remove the first 8192 samples and everything after 8192*300 samples

```julia
s = trim_channel(s, 8192*300, start=8192)
```


*source:*
[EEG/src/types/SSR/SSR.jl:238](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/SSR.jl#L238)

---

### validate_triggers(t::Dict{K, V})
Validate trigger channel


*source:*
[EEG/src/preprocessing/triggers.jl:10](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/triggers.jl#L10)

---

### write_avr(fname::String, data::Array{T, N}, chanNames::Array{T, N}, fs::Number)
Write AVR file


*source:*
[EEG/src/read_write/avr.jl:55](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/read_write/avr.jl#L55)

---

### write_dat(fname::String, X::AbstractArray{T, 1}, Y::AbstractArray{T, 1}, Z::AbstractArray{T, 1}, S::Array{Float64, 4}, T::AbstractArray{T, 1})
Write dat file


*source:*
[EEG/src/read_write/dat.jl:162](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/read_write/dat.jl#L162)

---

### Dipole
Dipole type.

Store the location, direction and state of a dipole

### Parameters

* coord_system: The coordinate system that the locations are stored in
* x,y,z: Location of dipole
* x,y,z/ori: Orientation of dipole
* color: Color of dipole for plotting
* state: State of dipol
* size: size of dipole



*source:*
[EEG/src/source_analysis/dipoles.jl:15](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/source_analysis/dipoles.jl#L15)

---

### SSR
## Steady State Response
This composite type contains the information for steady state response recordings and analysis.

### Fields

* `data`: contains the recorded data
* `trigers`: contains information about timing for creation of epochs
* `system_codes`: contains system information
* `samplingrate`: the sampling rate of the data
* `modulationrate`: the modulation rate of the stimulus
* `reference_channel`: the channel the data has been referenced to
* `file_path` and `file_name`: where the file was read in from
* `channel_names`: the names of the channels
* `processing`: dictionary type to store analysis
* `header`: additional information read from the file

### `processing` Fields
The following standard names are used when saving data to the processing dictionary.

* `Name`: The identifier for the participant
* `Side`: Side of stimulation
* `Carrier_Frequency`: Carrier frequency of the stimulus
* `Amplitude`: Amplitude of the stimulus
* `epochs`: The epochs extracted from the recording
* `sweeps`: The extracted sweeps from the recording


*source:*
[EEG/src/types/SSR/SSR.jl:30](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/types/SSR/SSR.jl#L30)

## Internal
---

### beamformer_type4(B::Array{T, N}, E::Array{T, N}, L::Array{T, N})
Type 4 beamformer as described in Huang et al 2004.

### Input

* Array of data to be beamformed. Channels x Samples
* Array of noise to be used. Channels x Samples
* Matrix of leadfield values. Dipole x 3 x Channels

### Optional arguments

* progress: display progress bar for analysis
* n: order of covariance matrix to calculate


*source:*
[EEG/src/source_analysis/beamformers.jl:20](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/source_analysis/beamformers.jl#L20)

---

### peak2peak(epochs)
Find the peak to peak value for each epoch to be returned to epoch_rejection()


*source:*
[EEG/src/preprocessing/data_rejection.jl:33](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/preprocessing/data_rejection.jl#L33)

---

### read_elp(fname::String)
Read elp file

(Not yet working, need to convert to 3d coord system)

### Input
* `fname`: Name or path for the sfp file

### Output
* `elec`: Electrodes object


*source:*
[EEG/src/read_write/elp.jl:17](https://github.com/codles/EEG.jl/tree/913565146e3ad7b5d558462f262fa174ffb49f69/src/read_write/elp.jl#L17)

