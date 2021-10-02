"""
Abstract type to represent Electroencephalography (EEG) data.

The following types inherit from the EEG type and can be used to process your data:

- `GeneralEEG`: Used to store data without assumption of any experimental paradigm.
- `SSR`: Used to store data acquired with a steady state response experiment paradigm.
- `TR`: Used to store data acquired with a transient response experiment paradigm.

# Examples
```julia
data = # load your EEG data using for example read_EEG()

samplingrate(data)  # Returns the sampling rate
channelnames(data)  # Returns the channel names
```
"""
abstract type EEG <: NeuroimagingMeasurement end

import Base.show
function Base.show(io::IO, a::EEG)
    time_length = round.(size(a.data, 1) / samplingrate(Float64, a) / 60)
    println(
        io,
        "EEG measurement of $time_length mins with $(size(a.data,2)) channels sampled at $(a.samplingrate)",
    )
end

"""
Type for storing general EEG data without assumption of any experimental paradigm.

# Examples
```julia
s = read_EEG(filename)
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
GeneralEEG(args...; kwargs...) = read_EEG(args...; kwargs...)

"""
    samplingrate(t::Type, s::EEG)
    samplingrate(s::EEG)

Return the sampling rate of an EEG type in Hz as the requested type.
If no type is provided, the sampling rate is returned as a floating point number.

# Examples
```julia
s = read_EEG(filename)
samplingrate(s)
```
"""
samplingrate(s::EEG) = s.samplingrate |> u"Hz"
samplingrate(t, s::EEG) = convert(t, s.samplingrate |> u"Hz" |> ustrip)


"""
    times(t::Type, s::EEG)
    times(s::EEG)

Return the times associated with each sample in seconds.

# Examples
```julia
s = read_EEG(filename)
times(s)
```
"""
times(s::EEG) = collect(1:size(data(s), 1)) ./ samplingrate(Float64, s) .* u"s"
times(t, s::EEG) = convert.(t, times(s) |> ustrip)


"""
    channelnames(s::EEG)

Return the names of sensors in EEG measurement.

# Examples
```julia
s = read_EEG(filename)
channelnames(s)
```
"""
channelnames(s::EEG) = labels(s.sensors)

"""
    channelnames(s::EEG, i::Int, l::AbstractString)
    channelnames(s::EEG, l::AbstractVector{AbstractString})

Change the names of `i`th sensors in an EEG measurement `s` to `l`.
Or change the name of all sensors by pass a vector of strings.

# Examples
```julia
s = read_EEG(filename)
channelnames(s, 1, "Fp1")
```
"""
function channelnames(s::EEG, i::Int, l::S) where {S<:AbstractString}

    s.sensors[i].label = l
    return s
end
function channelnames(s::EEG, l::AbstractVector{S}) where {S<:AbstractString}
    @assert length(l) == length(channelnames(s))
    for li = 1:length(l)
        s = channelnames(s, li, l[li])
    end
    return s
end


"""
    data(s::EEG)
    data(s::EEG, channel::AbstractString)
    data(s::EEG, channels::AbstractVector{AbstractString})

Return the data stored in the type object.
This may be useful for integration with custom processing.

# Examples
```julia
s = read_EEG(filename)
data(s)
data(s, "Cz")
data(s, ["Cz", "P2"])
```
"""
data(s::EEG) = s.data
data(s::EEG, channel::AbstractString) = data(s, [channel])
function data(s::EEG, channels::AbstractVector{S}) where {S<:AbstractString}
    return data(s, _channel_indices(s, channels))
end
function data(s::EEG, channels::AbstractVector{S}) where {S<:Int}
    return deepcopy(s.data)[:, channels]
end


"""
    sensors(s::EEG)
    channelnames(s::EEG, l::AbstractVector{AbstractString})

Returns the sensors for an EEG recording.

# Examples
```julia
s = read_EEG(filename)
sensors(s)
```
"""
sensors(s::EEG) = s.sensors
electrodes(s::EEG) = s.sensors

#######################################
#
# EEG type operations
#
#######################################

import Base.hcat
"""
    hcat(a::EEG, b::EEG)

Concatenate two EEG measurements together, effectively creating a single long measurement.

# Examples
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
# Change reference channels
#
#######################################

"""
    rereference(a::EEG, refChan::Union{AbstractString, Array{AbstractString}}; kwargs...)

Reference data to specified channel(s).

#### Example

```julia
a = rereference(a, "Cz")
# or
a = rereference(a, ["P9", "P10"])
```

"""
function rereference(
    a::EEG,
    refChan::Union{S,Array{S}};
    kwargs...,
) where {S<:AbstractString}

    a.data = rereference(a.data, refChan, channelnames(a))

    a.reference_channel = [refChan]

    return a
end



#######################################
#
# Manipulate channels
#
#######################################

"""
    add_channel(a::EEG, data::Vector, chanLabel::AbstractString)

Add a channel to the EEG type with specified channel names.

# Examples
```julia
s = read_EEG(filename)
new_channel = mean(s.data, 2)
s = add_channel(s, new_channel, "MeanChannelData")
```
"""
function add_channel(a::EEG, data::Vector, chanLabel::AbstractString; kwargs...)

    @info("Adding channel $chanLabel")

    a.data = hcat(a.data, data)
    push!(a.sensors, Electrode(chanLabel, Talairach(NaN, NaN, NaN), Dict()))

    return a
end


"""
    remove_channel!(a::EEG, channelname::AbstractString)
    remove_channel!(a::EEG, channelnames::Array{AbstractString})
    remove_channel!(a::EEG, channelidx::Int)
    remove_channel!(a::EEG, channelidxs::Array{Int})

Remove channel(s) from EEG as specifed by `channelname` or `channelidx`.

# Examples
```julia
a = read_EEG(filename)
remove_channel!(a, ["TP8", "Cz"])
```
"""
function remove_channel!(a::EEG, channel_name::S; kwargs...) where {S<:AbstractString}
    @debug("Removing channel $(channel_name)")
    remove_channel!(a, [channel_name])
end

function remove_channel!(
    a::EEG,
    channel_names::Array{S};
    kwargs...,
) where {S<:AbstractString}
    @debug("Removing channels $(join(channel_names, " "))")
    remove_channel!(a, _channel_indices(a, channel_names))
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
    keep_channel!(a::EEG, channelname::AbstractString)
    keep_channel!(a::EEG, channelnames::Array{AbstractString})
    keep_channel!(a::EEG, channelidxs::Array{Int})

Remove all channels except those requested from EEG.

# Examples
```julia
a = read_EEG(filename)
keep_channel!(a, ["P8", "Cz"])
```
"""
function keep_channel!(a::EEG, channel_name::AbstractString; kwargs...)
    keep_channel!(a, [channel_name]; kwargs...)
end

function keep_channel!(
    a::EEG,
    channel_names::AbstractVector{S};
    kwargs...,
) where {S<:AbstractString}
    @info("Keeping channel(s) $(join(channel_names, " "))")
    keep_channel!(a, _channel_indices(a, channel_names))
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
    trim_channel(a::EEG, stop::Int; start::Int=1)

Trim EEG recording by removing data after `stop` specifed samples
and optionally before `start` samples.

# Examples
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
    merge_channels(a::EEG, merge_Chans::Array{S}, new_name::S) where {S<:AbstractString}
    merge_channels(a::EEG, merge_Chans::S, new_name::S) where {S<:AbstractString}
                                                        
Average `EEG` channels listed in `merge_Chans` and label the averaged channel as `new_name`.

# Examples
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

    keep_idxs = _channel_indices(a, merge_Chans)

    if sum(keep_idxs .== 0) > 0
        @warn(
            "Could not merge as these channels don't exist: $(join(vec(merge_Chans[keep_idxs .== 0]), " "))"
        )
        keep_idxs = keep_idxs[keep_idxs.>0]
    end

    @info("Merging channels $(join(vec(channelnames(a)[keep_idxs,:]), " "))")
    @debug("Merging channels $keep_idxs")

    a = add_channel(
        a,
        vec(Statistics.mean(a.data[:, keep_idxs], dims = 2)),
        new_name;
        kwargs...,
    )
end

function merge_channels(
    a::EEG,
    merge_Chans::S,
    new_name::S;
    kwargs...,
) where {S<:AbstractString}
    a = merge_channels(a, [merge_Chans], new_name; kwargs...)
end


"""
    read_EEG(fname::AbstractString)
    read_EEG(args...)

Read a file or IO stream and store the data in an `GeneralEEG` type.

# Arguments

- `fname`: Name of the file to be read
- `min_epoch_length`: Minimum epoch length in samples. Shorter epochs will be removed (0)
- `max_epoch_length`: Maximum epoch length in samples. Longer epochs will be removed (0 = all)
- `valid_triggers`: Triggers that are considered valid, others are removed ([1,2])
- `stimulation_amplitude`: Amplitude of stimulation (NaN)
- `remove_first`: Number of epochs to be removed from start of recording (0)
- `max_epochs`: Maximum number of epochs to retain (0 = all)

# Supported file formats

- BIOSEMI (.bdf)
"""
function read_EEG(
    fname::AbstractString;
    valid_triggers::Array{Int} = [1, 2],
    min_epoch_length::Int = 0,
    max_epoch_length::Int = 0,
    remove_first::Int = 0,
    max_epochs::Int = 0,
    kwargs...,
)

    @info("Importing EEG from file: $fname")
    file_path, file_name, ext = fileparts(fname)


    #
    # Read file data
    #

    # Import raw data
    if ext == "bdf"
        data, triggers, system_codes, samplingrate, reference_channel, header =
            import_biosemi(fname; kwargs...)
    else
        warn("File type $ext is unknown")
    end

    # Create electrodes
    elecs = Electrode[]
    for e in header["chanLabels"]
        push!(elecs, Electrode(e, Talairach(NaN * u"m", NaN * u"m", NaN * u"m"), Dict()))
    end

    # Create EEG type
    if unit(samplingrate) == unit(1.0u"Hz")
        #nothing
    else
        samplingrate = samplingrate * 1.0u"Hz"
    end

    a = GeneralEEG(
        data,
        elecs,
        triggers,
        system_codes,
        samplingrate,
        [reference_channel],
        file_path,
        file_name,
        Dict(),
        header,
    )

    #
    # Clean up
    #

    # Remove status channel information
    remove_channel!(a, "Status")

    # Clean epoch index
    a.triggers = clean_triggers(
        a.triggers,
        valid_triggers,
        min_epoch_length,
        max_epoch_length,
        remove_first,
        max_epochs,
    )

    # Try and match sensor names to known locations
    locs = read_elp(joinpath(datadep"BioSemi64Locations", "biosemi64.elp"))
    new_sens, idx = match_sensors(locs, labels(sensors(a)))
    if length(new_sens) == length(sensors(a))
        @debug("Sucsessfully matches location of all sensors, using new locations")
        a.sensors = new_sens
    end

    return a
end


function trigger_channel(a::EEG; kwargs...)

    create_channel(a.triggers, a.data, samplingrate(Float64, a))
end


function system_code_channel(a::EEG; kwargs...)

    create_channel(a.system_codes, a.data, samplingrate(Float64, a))
end


"""
    epoch_rejection(a::EEG; retain_percentage::Number = 0.95, kwargs...)

Reject epochs such that `retain_percentage` is retained.
"""
function epoch_rejection(a::EEG; retain_percentage::Number = 0.95, kwargs...)

    a.processing["epochs"] =
        epoch_rejection(a.processing["epochs"], retain_percentage; kwargs...)

    return a
end
