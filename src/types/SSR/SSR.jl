typealias FreqHz{T} SIUnits.SIQuantity{T,0,0,-1,0,0,0,0,0,0}


@doc """
## Steady State Response
This composite type contains the information for steady state response recordings and analysis.

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

#### `processing` Fields
The following standard names are used when saving data to the processing dictionary.

* `Name`: The identifier for the participant
* `Side`: Side of stimulation
* `Carrier_Frequency`: Carrier frequency of the stimulus
* `Amplitude`: Amplitude of the stimulus
* `epochs`: The epochs extracted from the recording
* `sweeps`: The extracted sweeps from the recording
""" ->
type SSR
    data::Array
    triggers::Dict
    system_codes::Dict
    samplingrate::FreqHz{Number}
    modulationrate::FreqHz{Number}
    reference_channel::Array{AbstractString, 1}
    file_path::AbstractString
    file_name::AbstractString
    channel_names::Array{AbstractString, 1}
    processing::Dict
    header::Dict
end


#######################################
#
# SSR info
#
#######################################

@doc """
Return the sampling rate of a steady state type.
If no type is provided, the sampling rate is returned as a floating point.

#### Example

Return the sampling rate of a recording

```julia
s = read_SSR(filename)
samplingrate(s)
```
""" ->
samplingrate(t, s::SSR) = convert(t, float(s.samplingrate))
samplingrate(s::SSR) = samplingrate(AbstractFloat, s)


@doc """
Return the modulation rate of a steady state type.
If no type is provided, the modulation rate is returned as a floating point.

#### Example

Return the modulation rate of a recording

```julia
s = read_SSR(filename)
modulationrate(s)
```
""" ->
modulationrate(t, s::SSR) = convert(t, float(s.modulationrate))
modulationrate(s::SSR) = modulationrate(AbstractFloat, s)


#######################################
#
# Show
#
#######################################

import Base.show
function Base.show(io::IO, a::SSR)
    time_length = round(size(a.data,1) / samplingrate(a) / 60, 2)
    println(io, "SSR measurement of $time_length mins with $(size(a.data,2)) channels sampled at $(a.samplingrate)")
    println(io, "  Modulation frequency: $(a.modulationrate )")

    if haskey(a.processing, "Amplitude")
        println(io, "  Stimulation amplitude: $(a.processing["Amplitude"]) dB")
    end
    if haskey(a.processing, "Name")
        println(io, "  Participant name: $(a.processing["Name"] )")
    end
    if haskey(a.processing, "Side")
        println(io, "  Stimulation side: $(a.processing["Side"] )")
    end
    if haskey(a.processing, "Carrier_Frequency")
        println(io, "  Carrier frequency: $(a.processing["Carrier_Frequency"] ) Hz")
    end

end


#######################################
#
# Operate on type
#
#######################################

import Base.hcat
@doc """
Append one SSR type to another, simulating a longer recording.

#### Example

```julia
hcat(a, b)
```
""" ->
function hcat(a::SSR, b::SSR)

    if haskey(a.processing, "epochs")
        warn("Epochs have already been extracted and will no longer be valid")
    end
    if haskey(a.processing, "statistics")
        warn("Statistics have already been calculated and will no longer be valid")
    end

    debug("Appending two SSRs with $(size(a.data, 2)) & $(size(b.data, 2)) channels and lengths $(size(a.data, 1)) $(size(b.data, 1))")

    join_triggers(a, b)
    a.data = [a.data; b.data]

    return a
end


@doc """
Append the trigger information of one SSR type to another.
Places the trigger information at the end of first file

#### Example

```julia
join_triggers(a, b)
```
""" ->
function join_triggers(a, b; offset=size(a.data, 1))

    a.triggers["Index"] = [a.triggers["Index"]; (b.triggers["Index"] .+ offset)]
    a.triggers["Code"] = [a.triggers["Code"]; b.triggers["Code"]]
    a.triggers["Duration"] = [a.triggers["Duration"]'; b.triggers["Duration"]']'

    a
end




#######################################
#
# Manipulate channels
#
#######################################

@doc """
Add a channel to the SSR type with specified channel names.

#### Example

Add a channel called `Merged`

```julia
s = read_SSR(filename)
new_channel = mean(s.data, 2)
s = add_channel(s, new_channel, "Merged")
```
""" ->
function add_channel(a::SSR, data::Array, chanLabels::AbstractString; kwargs...)

    Logging.info("Adding channel $chanLabels")

    a.data = hcat(a.data, data)
    push!(a.channel_names, chanLabels)

    return a
end


@doc """
Remove specified channels from SSR.

#### Example

Remove channel Cz and those in the set called `EEG_Vanvooren_2014_Right`

```julia
a = read_SSR(filename)
remove_channel!(a, [EEG_Vanvooren_2014_Right, "Cz"])
```
""" ->
function remove_channel!(a::SSR, channel_names::Array{ASCIIString}; kwargs...)
    Logging.info("4 Removing channel(s) $(join(channel_names, " "))")
    remove_channel!(a, round(Int, [findfirst(a.channel_names, c) for c=channel_names]))
end

function remove_channel!(a::SSR, channel_idx::Array{Int}; kwargs...)

    channel_idx = channel_idx[channel_idx .!= 0]

    Logging.info("3 Removing channel(s) $channel_idx")

    keep_idx = [1:size(a.data)[end]; ]
    for c = sort(channel_idx, rev=true)
        try
            splice!(keep_idx, c)
        end
    end

    a.data = a.data[:, keep_idx]

    a.channel_names = a.channel_names[keep_idx]

    return a
end

function remove_channel!(a::SSR, channel_names::Union{Array{AbstractString}}; kwargs...)
    Logging.info("2 Removing channel(s) $(join(channel_names, " "))")
    remove_channel!(a, convert(Array{ASCIIString}, channel_names)); end

function remove_channel!(a::SSR, channel_name::Union{Int, AbstractString, ASCIIString}; kwargs...)
    Logging.info("1 Removing channel(s) $(join(channel_name, " "))")
    remove_channel!(a, [channel_name]); end


@doc """
Remove all channels except those requested from SSR.

#### Example

Remove all channels except Cz and those in the set called `EEG_Vanvooren_2014_Right`

```julia
a = read_SSR(filename)
keep_channel!(a, [EEG_Vanvooren_2014_Right, "Cz"])
```
""" ->
function keep_channel!(a::SSR, channel_names::Array{ASCIIString}; kwargs...)
    Logging.info("Keeping channel(s) $(join(channel_names, " "))")
    keep_channel!(a, round(Int, [findfirst(a.channel_names, c) for c=channel_names]))
end

function keep_channel!(a::SSR, channel_name::AbstractString; kwargs...)
    keep_channel!(a, [channel_name]; kwargs...)
end

function keep_channel!(a::SSR, channel_idx::Array{Int}; kwargs...)

    remove_channels = [1:size(a.data,2); ]

    channel_idx = sort(channel_idx, rev=true)
    for c = channel_idx
        splice!(remove_channels, c)
    end

    remove_channel!(a, remove_channels; kwargs...)
end


#######################################
#
# Trim channels
#
#######################################

@doc """
Trim SSR recording by removing data after `stop` specifed samples.

#### Optional Parameters

* `start` Remove samples before this value

#### Example

Remove the first 8192 samples and everything after 8192*300 samples

```julia
s = trim_channel(s, 8192*300, start=8192)
```
""" ->
function trim_channel(a::SSR, stop::Int; start::Int=1, kwargs...)

    Logging.info("Trimming $(size(a.data)[end]) channels between $start and $stop")

    a.data = a.data[start:stop,:]

    to_keep = find( (a.triggers["Index"] .>= start) & (a.triggers["Index"] .<= stop))
    a.triggers["Index"] = a.triggers["Index"][to_keep]
    a.triggers["Duration"] = a.triggers["Duration"][to_keep]
    a.triggers["Code"] = a.triggers["Code"][to_keep]
    a.triggers["Index"] -= (start-1)

    to_keep = find( (a.system_codes["Index"] .>= start) & (a.system_codes["Index"] .<= stop))
    a.system_codes["Index"]    = a.system_codes["Index"][to_keep]
    a.system_codes["Duration"] = a.system_codes["Duration"][to_keep]
    a.system_codes["Code"]     = a.system_codes["Code"][to_keep]
    a.system_codes["Index"] -= (start-1)

    return a
end


#######################################
#
# Merge channels
#
#######################################

@doc """
Merge `SSR` channels listed in `merge_Chans` and label the averaged channel as `new_name`

#### Example

```julia
s = merge_channels(s, ["P6", "P8"], "P68")
```
""" ->
function merge_channels(a::SSR, merge_Chans::Array{ASCIIString}, new_name::ASCIIString; kwargs...)

    debug("Total origin channels: $(length(a.channel_names))")

    keep_idxs = [findfirst(a.channel_names, i) for i = merge_Chans]

    if sum(keep_idxs .== 0) > 0
        warn("Could not merge as these channels don't exist: $(join(vec(merge_Chans[keep_idxs .== 0]), " "))")
        keep_idxs = keep_idxs[keep_idxs .> 0]
    end

    Logging.info("Merging channels $(join(vec(a.channel_names[keep_idxs,:]), " "))")
    debug("Merging channels $keep_idxs")

    a = add_channel(a, mean(a.data[:,keep_idxs], 2), new_name; kwargs...)
end

function merge_channels(a::SSR, merge_Chans::ASCIIString, new_name::ASCIIString; kwargs...)
    a = merge_channels(a, [merge_Chans], new_name; kwargs...)
end


#######################################
#
# Helper functions
#
#######################################

function assr_frequency(rounded_freq::Number; stimulation_samplingrate::Number=32000,
                        stimulation_frames_per_epoch::Number=32768)

    round(rounded_freq/(stimulation_samplingrate / stimulation_frames_per_epoch)) *
                                                                stimulation_samplingrate / stimulation_frames_per_epoch
end

function assr_frequency(rounded_freq::AbstractVector)

    [assr_frequency(f) for f = rounded_freq]
end
