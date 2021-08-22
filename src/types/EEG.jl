"""
Abstract type for storing Electroencephalography (EEG) data.

Other types inherit from this EEG type.
All EEG types support the following functions:

* `samplingrate()`
* `channelnames()`
* `remove_channel!()`
* `keep_channel!()`
* `trim_channel()`
* `highpass_filter()`
* `lowpass_filter()`
* `rereference()`

```julia
data = # load your EEG data using for example read_SSR()

samplingrate(data)  # Returns the sampling rate
channelnames(data)  # Returns the channel names
```
    
"""
abstract type EEG end

"""
Type for storing general EEG data without assumption of any experimental paradigm.

#### Example

```julia
s = GeneralEEG("filename.bdf")
s = rereference(s, "Cz")
s = remove_channel!(s, "Cz")
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


"""
Return the names of sensors in EEG measurement.

#### Example

```julia
s = read_SSR(filename)
channelnames(s)
```
"""
channelnames(s::EEG) = labels(s.sensors)

"""
Change the names of sensors in EEG measurement.

#### Example

```julia
s = read_SSR(filename)
channelnames(s, 1, "Fp1")
```
"""
function channelnames(s::EEG, i::Int, l::S) where {S<:AbstractString}

    s.sensors[i].label = l
    return s
end
function channelnames(s::EEG, l::AbstractVector{S}) where {S<:AbstractString}
    for li = 1:length(l)
        s = channelnames(s, li, l[li])
    end
    return s
end


import Base.show
function Base.show(io::IO, a::EEG)
    time_length = round.(size(a.data, 1) / samplingrate(a) / 60)
    println(
        io,
        "EEG measurement of $time_length mins with $(size(a.data,2)) channels sampled at $(a.samplingrate)",
    )
end




#######################################
#
# Operate on type
#
#######################################

import Base.hcat
"""
Append one EEG type to another, simulating a longer recording.

#### Example

```julia
hcat(a, b)
```
"""
function hcat(a::EEG, b::EEG)

    if channelnames(a) != channelnames(b)
        throw(
            ArgumentError(
                string("Channels do not match $(channelnames(a)) != $(channelnames(b))"),
            ),
        )
    end

    if haskey(a.processing, "epochs")
        @warn("Epochs have already been extracted and will no longer be valid")
    end
    if haskey(a.processing, "statistics")
        @warn("Statistics have already been calculated and will no longer be valid")
    end

    @debug(
        "Appending two EEGs with $(size(a.data, 2)) .& $(size(b.data, 2)) channels and lengths $(size(a.data, 1)) $(size(b.data, 1))"
    )

    join_triggers(a, b)
    a.data = [a.data; b.data]

    return a
end


"""
Append the trigger information of one EEG type to another.
Places the trigger information at the end of first file

#### Example

```julia
join_triggers(a, b)
```
"""
function join_triggers(a, b; offset = size(a.data, 1))

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

"""
Add a channel to the SSR type with specified channel names.

#### Example

Add a channel called `Merged`

```julia
s = read_SSR(filename)
new_channel = mean(s.data, 2)
s = add_channel(s, new_channel, "Merged")
```
"""
function add_channel(a::EEG, data::Vector, chanLabel::AbstractString; kwargs...)

    @info("Adding channel $chanLabel")

    a.data = hcat(a.data, data)
    push!(a.sensors, Electrode(chanLabel, Talairach(NaN, NaN, NaN), Dict()))

    return a
end


"""
Remove specified channels from EEG.

#### Example

Remove channel Cz and those in the set called `EEG_Vanvooren_2014_Right`

```julia
a = read_SSR(filename)
remove_channel!(a, [EEG_Vanvooren_2014_Right, "Cz"])
```
"""
function remove_channel!(
    a::EEG,
    channel_names::Array{S};
    kwargs...,
) where {S<:AbstractString}
    @debug("Removing channels $(join(channel_names, " "))")
    remove_channel!(
        a,
        Int[something(findfirst(isequal(c), channelnames(a)), 0) for c in channel_names],
    )
end

function remove_channel!(a::EEG, channel_name::S; kwargs...) where {S<:AbstractString}
    @debug("Removing channel $(channel_name)")
    remove_channel!(a, [channel_name])
end

remove_channel!(a::EEG, channel_names::Int; kwargs...) =
    remove_channel!(a, [channel_names]; kwargs...)

function remove_channel!(a::EEG, channel_idx::Array{Int}; kwargs...)

    channel_idx = channel_idx[channel_idx.!=0]

    @debug("Removing channel(s) $channel_idx")
    if any(channel_idx .== 0)
        @warn("Failed to remove a channel")
    end

    keep_idx = [1:size(a.data)[end];]
    for c in sort(channel_idx, rev = true)
        try
            splice!(keep_idx, c)
        catch
            # Nothing
        end
    end

    if haskey(a.processing, "epochs")
        if size(a.processing["epochs"], 3) == size(a.data, 2)
            @debug("Removing channel(s) from epoch data")
            a.processing["epochs"] = a.processing["epochs"][:, :, keep_idx]
        end
    end
    if haskey(a.processing, "sweeps")
        if size(a.processing["sweeps"], 3) == size(a.data, 2)
            @debug("Removing channel(s) from sweep data")
            a.processing["sweeps"] = a.processing["sweeps"][:, :, keep_idx]
        end
    end

    a.data = a.data[:, keep_idx]
    a.sensors = a.sensors[keep_idx]

    return a
end


"""
Remove all channels except those requested from EEG.

#### Example

Remove all channels except Cz and those in the set called `EEG_Vanvooren_2014_Right`

```julia
a = read_SSR(filename)
keep_channel!(a, [EEG_Vanvooren_2014_Right, "Cz"])
```
"""
function keep_channel!(a::EEG, channel_names::Array{S}; kwargs...) where {S<:AbstractString}
    @info("Keeping channel(s) $(join(channel_names, " "))")
    keep_channel!(
        a,
        vec(
            round.(
                Int,
                [
                    something(findfirst(isequal(c), channelnames(a)), 0) for
                    c in channel_names
                ],
            ),
        ),
    )
end

function keep_channel!(a::EEG, channel_name::AbstractString; kwargs...)
    keep_channel!(a, [channel_name]; kwargs...)
end

function keep_channel!(a::EEG, channel_idx::AbstractVector{Int}; kwargs...)

    remove_channels = [1:size(a.data, 2);]

    channel_idx = sort(channel_idx, rev = true)
    for c in channel_idx
        splice!(remove_channels, c)
    end

    remove_channel!(a, remove_channels; kwargs...)
end


#######################################
#
# Trim channels
#
#######################################

"""
Trim EEG recording by removing data after `stop` specifed samples.

#### Optional Parameters

* `start` Remove samples before this value

#### Example

Remove the first 8192 samples and everything after 8192*300 samples

```julia
s = trim_channel(s, 8192*300, start=8192)
```
"""
function trim_channel(a::EEG, stop::Int; start::Int = 1, kwargs...)

    @info("Trimming $(size(a.data)[end]) channels between $start and $stop")

    a.data = a.data[start:stop, :]

    to_keep = findall((a.triggers["Index"] .>= start) .& (a.triggers["Index"] .<= stop))
    a.triggers["Index"] = a.triggers["Index"][to_keep]
    a.triggers["Duration"] = a.triggers["Duration"][to_keep]
    a.triggers["Code"] = a.triggers["Code"][to_keep]
    a.triggers["Index"] .-= (start - 1)

    to_keep =
        findall((a.system_codes["Index"] .>= start) .& (a.system_codes["Index"] .<= stop))
    a.system_codes["Index"] = a.system_codes["Index"][to_keep]
    a.system_codes["Duration"] = a.system_codes["Duration"][to_keep]
    a.system_codes["Code"] = a.system_codes["Code"][to_keep]
    a.system_codes["Index"] .-= (start - 1)

    return a
end


#######################################
#
# Merge channels
#
#######################################

"""
Merge `EEG` channels listed in `merge_Chans` and label the averaged channel as `new_name`

If multiple channels are listed then the average of those channels will be added.

#### Example

```julia
s = merge_channels(s, ["P6", "P8"], "P68")
```
"""
function merge_channels(
    a::EEG,
    merge_Chans::Array{S},
    new_name::S;
    kwargs...,
) where {S<:AbstractString}

    @debug("Number of original channels: $(length(channelnames(a)))")

    keep_idxs =
        vec([something(findfirst(isequal(i), channelnames(a)), 0) for i in merge_Chans])

    if sum(keep_idxs .== 0) > 0
        @warn(
            "Could not merge as these channels don't exist: $(join(vec(merge_Chans[keep_idxs .== 0]), " "))"
        )
        keep_idxs = keep_idxs[keep_idxs.>0]
    end

    @info("Merging channels $(join(vec(channelnames(a)[keep_idxs,:]), " "))")
    @debug("Merging channels $keep_idxs")

    a = add_channel(a, vec(mean(a.data[:, keep_idxs], dims = 2)), new_name; kwargs...)
end

function merge_channels(
    a::EEG,
    merge_Chans::S,
    new_name::S;
    kwargs...,
) where {S<:AbstractString}
    a = merge_channels(a, [merge_Chans], new_name; kwargs...)
end
