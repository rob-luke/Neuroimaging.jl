"""
Type for storing data acquired with a transient response (TR) experimental paradigm.

#### Example

Put an example here

```julia
s = read_TR("filename")
s = rereference(s, "Cz")
```

"""
mutable struct TR <: EEG
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


#######################################
#
# Show
#
#######################################

import Base.show
function Base.show(io::IO, a::TR)
    time_length = round.(size(a.data, 1) / samplingrate(Float64, a) / 60)
    println(
        io,
        "Transient response measurement of $time_length mins with $(size(a.data,2)) channels sampled at $(samplingrate(a))",
    )

end


#######################################
#
# Read data
#
#######################################


"""
    read_TR(fname::AbstractString)
    read_TR(args...)

Read a file or IO stream and store the data in an `TR` type.

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
function read_TR(
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

    a = TR(
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
