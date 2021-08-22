"""

Abstract type for storing Electroencephalography (EEG) data.

Other types inherit from this EEG type.
And common functions can be run on all EEG sub types.

```julia
data = # load your EEG data using for example read_SSR()

samplingrate(data)  # Returns the sampling rate
channelnames(data)  # Returns the channel names
highpass_filter(data)        # Returns the channel names
```
    
"""
abstract type EEG end

"""

Type for storing general EEG data without assumption of any experimental paradigm .

The minimum required information for SSR recording is stored in the type.
Additional information can be stored in the `processing` field.
To facilitate processing, specific names are used in the processing dictionary.

#### Fields

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

#### Additional `processing` fields
The following standard names are used when saving data to the processing dictionary.

* `Name`: The identifier for the participant
* `Side`: Side of stimulation
* `Carrier_Frequency`: Carrier frequency of the stimulus
* `Amplitude`: Amplitude of the stimulus
* `epochs`: The epochs extracted from the recording
* `sweeps`: The extracted sweeps from the recording


#### Example

Put an example here

```julia
s = SSR("filename")
```

"""
mutable struct GeneralEEG <: EEG
    data::Array
    sensors::Array{Sensor}
    triggers::Dict
    system_codes::Dict
    samplingrate::typeof(1.0u"Hz")
    reference_channel::Array{AbstractString,1}
    file_path::AbstractString
    file_name::AbstractString
    processing::Dict
    header::Dict
end


"""
Return the sampling rate of a steady state type.
If no type is provided, the sampling rate is returned as a floating point.

#### Example

Return the sampling rate of a recording

```julia
s = read_SSR(filename)
samplingrate(s)
```
"""
samplingrate(t, s::EEG) = convert(t, ustrip(s.samplingrate))
samplingrate(s::EEG) = samplingrate(AbstractFloat, s)