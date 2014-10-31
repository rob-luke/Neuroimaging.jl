using DataFrames
using MAT
using SIUnits
import SIUnits
using Docile

typealias FreqHz{T} SIUnits.SIQuantity{T,0,0,-1,0,0,0,0}

type SSR
    data::Array
    triggers::Dict
    system_codes::Dict
    sample_rate::FreqHz{Number}
    modulation_frequency::FreqHz{Number}
    reference_channel::Array{String}
    file_path::String
    file_name::String
    channel_names::Array{String}
    processing::Dict
end


import Base.show
function Base.show(io::IO, a::SSR)
    time_length = round(size(a.data,1) / a.sample_rate / 60, 2)
    println(io, "SSR measurement of $time_length mins with $(size(a.data,2)) channels sampled at $(a.sample_rate)")
    println(io, "  Modulation frequency: $(a.modulation_frequency )")

    if haskey(a.processing, "Amplitude")
        println(io, "  Stimulation amplitude: $(a.processing["Amplitude"]) dB")
    end
    if haskey(a.processing, "Name")
        println(io, "  Participant name: $(a.processing["Name"] )")
    end
    if haskey(a.processing, "Side")
        println(io, "  Stimulation side: $(a.processing["Side"] )")
    end

end


#######################################
#
# Read SSR
#
#######################################

@doc md"""
Read a file or IO stream and store the data in an SSR type.

Matching .mat files are read and modulation frequency information extracted.
Failing that, user passed arguments are used or the modulation frequency is extracted from the file name.

### Optional arguments

* min_epoch_length: Minimum epoch length in samples. Shorter epochs will be removed.
* max_epoch_length: Maximum epoch length in samples. Longer epochs will be removed.

### Supported file formats

* BIOSEMI .bdf


""" ->
function read_SSR(fname::Union(String, IO);
                  stimulation_amplitude::Number=NaN,   # User can set these
                  modulation_frequency::Number=NaN,    # values, but if not
                  stimulation_side::String="",         # then attempt to read
                  participant_name::String="",         # from file name or mat
                  kwargs...)

    info("Importing SSR from file: $fname")

    if isa(fname, String)
        file_path, file_name, ext = fileparts(fname)
    else
        warn("Filetype is IO. Might be bugged")
        file_path = "IO"; file_name = fname; ext = "IO"
    end


    #
    # Extract meta data
    #

    # Extract frequency from the file name if not set manually
    if contains(file_name, "Hz") && isnan(modulation_frequency)
        a = match(r"[-_](\d+[_.]?[\d+]?)Hz|Hz(\d+[_.]?[\d+]?)[-_]", file_name).captures
        modulation_frequency = assr_frequency(float(a[[i !== nothing for i = a]][1])) * Hertz
        debug("Extracted modulation frequency from file name: $modulation_frequency")
    end

    # Or even better if there is a mat file read it
    mat_path = string(file_path, file_name, ".mat")
    if isreadable(mat_path)
        modulation_frequency, stimulation_side, participant_name, stimulation_amplitude = read_rba_mat(mat_path)
    end


    #
    # Read file data
    #

    # Import raw data
    if ext == "bdf"
        data, triggers, system_codes, sample_rate, reference_channel, header = import_biosemi(fname)
    else
        warn("File type $ext is unknown")
    end

    # Create SSR type
    a = SSR(data, triggers, system_codes, sample_rate * Hertz, modulation_frequency,
            [reference_channel], file_path, file_name, header["chanLabels"], Dict())


    #
    # Store meta data in processing dictionary
    #

    if stimulation_side != ""
        a.processing["Side"] = stimulation_side
    end
    if participant_name != ""
        a.processing["Name"] = participant_name
    end
    if !isnan(stimulation_amplitude)
        a.processing["Amplitude"] = stimulation_amplitude
    end


    #
    # Clean up
    #

    # Remove status channel information
    remove_channel!(a, "Status")

    # Clean epoch index
    a.triggers = clean_triggers(a.triggers; kwargs...)

    return a
end




#######################################
#
# Read event files
#
#######################################

function read_evt(a::SSR, fname::String; kwargs...)
    d = read_evt(fname, a.sample_rate; kwargs...)
    validate_triggers(d)
    a.triggers = d
    return a
end


#######################################
#
# Add channels
#
#######################################

function add_channel(a::SSR, data::Array, chanLabels::ASCIIString; kwargs...)

    info("Adding channel $chanLabels")

    a.data = hcat(a.data, data)
    push!(a.channel_names, chanLabels)

    return a
end


#######################################
#
# Remove channels
#
#######################################

@doc md"""
Remove channels from SSR.

### Example

```julia
a = read_SSR(filename)
    remove_channel!(a, [EEG_Vanvooren_2014_Right, "Cz"])

```
""" ->
function remove_channel!(a::SSR, channel_names::Array{ASCIIString}; kwargs...)
    remove_channel!(a, int([findfirst(a.channel_names, c) for c=channel_names]))
    info("Removing channel(s) $(append_strings(channel_names))"); end

function remove_channel!(a::SSR, channel_idx::Array{Int}; kwargs...)

    channel_idx = channel_idx[channel_idx .!= 0]

    info("Removing channel(s) $channel_idx")

    keep_idx = [1:size(a.data)[end]]
    for c = sort(channel_idx, rev=true)
        try
            splice!(keep_idx, c)
        end
    end

    a.data = a.data[:, keep_idx]

    a.channel_names = a.channel_names[keep_idx]
end

function remove_channel!(a::SSR, channel_names::Union(Array{String}); kwargs...)
    remove_channel!(a, convert(Array{ASCIIString}, channel_names)); end

function remove_channel!(a::SSR, channel_name::Union(Int, String, ASCIIString); kwargs...)
    remove_channel!(a, [channel_name]); end


@doc md"""
Remove all channels except those requested from SSR.

### Example

```julia
a = read_SSR(filename)
    keep_channel!(a, [EEG_Vanvooren_2014_Right, "Cz"])

```
""" ->
function keep_channel!(a::SSR, channel_idx::Array{Int}; kwargs...)

    remove_channels = [1:size(a.data,2)]

    channel_idx = sort(channel_idx, rev=true)
    for c = channel_idx
        splice!(remove_channels, c)
    end

    remove_channel!(a, remove_channels; kwargs...)

end

function keep_channel!(a::SSR, channel_names::Array{ASCIIString}; kwargs...)
    info("Keeping channel(s) $(append_strings(channel_names))")
    keep_channel!(a, int([findfirst(a.channel_names, c) for c=channel_names]))
end



#######################################
#
# Trim channels
#
#######################################

function trim_channel(a::SSR, stop::Int; start::Int=1, kwargs...)

    info("Trimming $(size(a.data)[end]) channels between $start and $stop")

    a.data = a.data[start:stop,:]

    to_keep = find(a.triggers["Index"] .<= stop)
    a.triggers["Index"]        = a.triggers["Index"][to_keep]
    a.triggers["Duration"]     = a.triggers["Duration"][to_keep]
    a.triggers["Code"]         = a.triggers["Code"][to_keep]

    to_keep = find(a.system_codes["Index"] .<= stop)
    a.system_codes["Index"]    = a.system_codes["Index"][to_keep]
    a.system_codes["Duration"] = a.system_codes["Duration"][to_keep]
    a.system_codes["Code"]     = a.system_codes["Code"][to_keep]

    return a
end


#######################################
#
# Merge channels
#
#######################################

function merge_channels(a::SSR, merge_Chans::Array{ASCIIString}, new_name::String; kwargs...)

    debug("Total origin channels: $(length(a.channel_names))")

    keep_idxs = [findfirst(a.channel_names, i) for i = merge_Chans]
    keep_idxs = int(keep_idxs)

    if sum(keep_idxs .== 0) > 0
        warn("Could not merge channels as don't exist: $(append_strings(vec(merge_Chans[keep_idxs .== 0])))")
        keep_idxs = keep_idxs[keep_idxs .> 0]
    end

    info("Merging channels $(append_strings(vec(a.channel_names[keep_idxs,:])))")
    debug("Merging channels $keep_idxs")

    a = add_channel(a, mean(a.data[:,keep_idxs], 2), new_name; kwargs...)
end

function merge_channels(a::SSR, merge_Chans::ASCIIString, new_name::String; kwargs...)

    a = merge_channels(a, [merge_Chans], new_name; kwargs...)

end


#######################################
#
# Filtering
#
#######################################


function highpass_filter(a::SSR; cutOff::Number=2, order::Int=3, tolerance::Number=0.01, kwargs...)

    a.data, f = highpass_filter(a.data, cutOff=cutOff, order=order, fs=int(a.sample_rate))

    _filter_check(f, float(a.modulation_frequency), int(a.sample_rate), tolerance)

    _append_filter(a, f)
end


function lowpass_filter(a::SSR; cutOff::Number=150, order::Int=3, tolerance::Number=0.01, kwargs...)

    a.data, f = lowpass_filter(a.data, cutOff=cutOff, order=order, fs=int(a.sample_rate))

    _filter_check(f, float(a.modulation_frequency), int(a.sample_rate), tolerance)

    _append_filter(a, f)
end


function bandpass_filter(a::SSR;
                         lower::Number=float(a.modulation_frequency)-1,
                         upper::Number=float(a.modulation_frequency)+1,
                         n::Int=24, rp::Number=0.0001, tolerance::Number=0.01, kwargs...)

    # Type 1 Chebychev filter
    # The default options here are optimised for modulation frequencies 4, 10, 20, 40, 80
    # TODO filter check does not work here. Why not?
    # TODO automatic minimum filter order selection

    a.data, f = bandpass_filter(a.data, lower, upper, int(a.sample_rate), n, rp)

    _filter_check(f, float(a.modulation_frequency), int(a.sample_rate), tolerance)

    _append_filter(a, f)
end


function _filter_check(f::Filter, mod_freq::Number, fs::Number, tolerance::Number)
    #
    # Ensure that the filter does not alter the modulation frequency greater than a set tolerance
    #

    mod_change = abs(freqz(f, mod_freq, fs))
    if mod_change > 1 + tolerance || mod_change < 1 - tolerance
        warn("Filtering has modified modulation frequency greater than set tolerance: $mod_change")
    end
    debug("Filter magnitude at modulation frequency: $(mod_change)")
end


function _append_filter(a::SSR, f::Filter; name::String="filter")
    #
    # Put the filter information in the SSR processing structure
    #

    key_name = new_processing_key(a.processing, "filter")
    merge!(a.processing, [key_name => f])

    return a
end


#######################################
#
# Change reference channels
#
#######################################

function rereference(a::SSR, refChan::Union(String, Array{ASCIIString}); kwargs...)

    a.data = rereference(a.data, refChan, a.channel_names)

    a.reference_channel = [refChan]

    return a
end


#######################################
#
# Rejection channels
#
#######################################

function channel_rejection(a::SSR; kwargs...)

    if haskey(a.processing, "epochs")

        data = reshape(a.processing["epochs"],
                size(a.processing["epochs"], 1) * size(a.processing["epochs"], 2), size(a.processing["epochs"],3))
    else
        data = a.data
    end

    valid = channel_rejection(data, kwargs...)

    info("Rejected $(sum(!valid)) channels $(append_strings(a.channel_names[find(!valid)]))")

    remove_channel!(a, a.channel_names[find(!valid)])

    return a
end


#######################################
#
# Add triggers for more epochs
#
#######################################


function add_triggers(a::SSR; kwargs...)

    debug("Adding triggers to reduce SSR. Using SSR modulation frequency")

    add_triggers(a, float(a.modulation_frequency); kwargs...)
end


function add_triggers(a::SSR, mod_freq::Number; kwargs...)

    debug("Adding triggers to reduce SSR. Using $(mod_freq)Hz")

    epochIndex = DataFrame(Code = a.triggers["Code"], Index = a.triggers["Index"]);
    epochIndex[:Code] = epochIndex[:Code] - 252

    add_triggers(a, mod_freq, epochIndex; kwargs...)
end


function add_triggers(a::SSR, mod_freq::Number, epochIndex; cycle_per_epoch::Int=1, kwargs...)

    info("Adding triggers to reduce SSR. Reducing $(mod_freq)Hz to $cycle_per_epoch cycle(s).")

    # Existing epochs
    existing_epoch_length   = median(diff(epochIndex[:Index]))     # samples
    existing_epoch_length_s = existing_epoch_length / float(a.sample_rate)
    debug("Existing epoch length: $(existing_epoch_length_s)s")

    # New epochs
    new_epoch_length_s = cycle_per_epoch / mod_freq
    new_epochs_num     = round(existing_epoch_length_s / new_epoch_length_s) - 2
    new_epoch_times    = [1:new_epochs_num]*new_epoch_length_s
    new_epoch_indx     = [0, round(new_epoch_times * float(a.sample_rate))]
    debug("New epoch length = $new_epoch_length_s")
    debug("New # epochs     = $new_epochs_num")

    # Place new epoch indices
    debug("Was $(length(epochIndex[:Index])) indices")
    new_indx = epochIndex[:Index][1:end-1] .+ new_epoch_indx'
    new_indx = reshape(new_indx', length(new_indx), 1)[1:end-1]
    debug("Now $(length(new_indx)) indices")

    # Place in dict
    new_code = int(ones(1, length(new_indx))) .+ 252
    a.triggers = ["Index" => vec(int(new_indx)'), "Code" => vec(new_code), "Duration" => ones(length(new_code), 1)']
    #TODO Possible the trigger duration of one is not long enough

    return a
end



#######################################
#
# Extract epochs
#
#######################################

@doc md"""
Extract epoch data from SSR.

### Optional arguments

* valid_triggers: Trigger numbers that are considered valid ([1,2])
* remove_first: Remove the first n triggers (0).
* remove_last: Remove the last n triggers (0)

### Example

```julia
epochs = extract_epochs(SSR, valid_triggers=[1,2])
```
""" ->
function extract_epochs(a::SSR; valid_triggers::AbstractArray=[1,2], remove_first::Int=0, remove_last::Int=0, kwargs...)

    merge!(a.processing, ["epochs" => extract_epochs(a.data, a.triggers, valid_triggers, remove_first, remove_last)])

    return a
end


function epoch_rejection(a::SSR; cutOff::Number=0.95, kwargs...)

    a.processing["epochs"] = epoch_rejection(a.processing["epochs"], cutOff)

    return a
end


function create_sweeps(a::SSR; epochsPerSweep::Int=64, kwargs...)

    merge!(a.processing, ["sweeps" => create_sweeps(a.processing["epochs"], epochsPerSweep)])

    return a
end


#######################################
#
# File IO
#
#######################################

function trigger_channel(a::SSR; kwargs...)

    create_channel(a.triggers, a.data, float(a.sample_rate))
end


function system_code_channel(a::SSR; kwargs...)

    create_channel(a.system_codes, a.data, float(a.sample_rate))
end


function write_SSR(a::SSR, fname::String; kwargs...)

    info("Saving $(size(a.data)[end]) channels to $fname")

    writeBDF(fname, a.data', trigger_channel(a), system_code_channel(a), int(a.sample_rate), chanLabels=a.channel_names)

end


#######################################
#
# Statistics
#
#######################################


function ftest(a::SSR, freq_of_interest::Number; side_freq::Number=0.5, ID::String="", spill_bins::Int=2, kwargs... )

    # TODO: Account for multiple applied filters
    if haskey(a.processing, "filter1")
        used_filter = a.processing["filter1"]
    else
        used_filter = nothing
    end

    snrDb, phase, signal, noise, statistic =
        ftest(a.processing["sweeps"], freq_of_interest, float(a.sample_rate), side_freq, used_filter, spill_bins)

    result = DataFrame(
                        ID                  = vec(repmat([ID], length(a.channel_names), 1)),
                        Channel             = copy(a.channel_names),
                        ModulationFrequency = copy(float(a.modulation_frequency)),
                        AnalysisType        = "ftest",
                        AnalysisFrequency   = freq_of_interest,
                        SignalPower         = vec(signal),
                        SignalPhase         = vec(phase),
                        NoisePower          = vec(noise),
                        SNRdB               = vec(snrDb),
                        Statistic           = vec(statistic)
                      )

    result = add_dataframe_static_rows(result, kwargs)

    key_name = new_processing_key(a.processing, "ftest")
    merge!(a.processing, [key_name => result])

    return a
end


# If more than one frequency of interest is specified then run for all
function ftest(a::SSR, freq_of_interest::Array; kwargs...)

    for f = freq_of_interest; a = ftest(a, f; kwargs...); end; return a
end


# If no frequency of interest is specified then use the modulation frequency
function ftest(a::SSR; kwargs...)

    ftest(a, float(a.modulation_frequency); kwargs...)
end


# Save ftest results to file
function save_results(a::SSR; name_extension::String="", kwargs...)

    file_name = string(a.file_name, name_extension, ".csv")

    # Rename to save space
    results = a.processing

    # Index of keys to be exported
    result_idx = find_keys_containing(results, "ftest")
    result_idx = [result_idx, find_keys_containing(results, "hotelling")]

    if length(result_idx) > 0

        to_save = get(results, collect(keys(results))[result_idx[1]], 0)

        if length(result_idx) > 1
            for k = result_idx[2:end]
                result_data = get(results, collect(keys(results))[k], 0)
                to_save = rbind(to_save, result_data)
            end
        end

    writetable(file_name, to_save)
    end

    info("File saved to $file_name")

    return a
end


#######################################
#
# Connectivity
#
#######################################

@doc md"""
Calculate phase lag index between SSR sensors.

This is a wrapper function for the SSR type.
The calculation of PLI is calculated using [Synchrony.jl](www.github.com/.....)
""" ->
function phase_lag_index(a::SSR, ChannelOrigin::Int, ChannelDestination::Int, freq_of_interest::Real;
     ID::String="", kwargs... )

    err("PLI code has not been validated. Do not use")

    info("Phase lag index on SSR channels $(a.channel_names[ChannelOrigin]) and $(a.channel_names[ChannelDestination]) for $freq_of_interest Hz")

    data = permutedims(a.processing["epochs"], [1, 3, 2])

    pli = phase_lag_index(data[:, [ChannelOrigin, ChannelDestination], :], freq_of_interest, float(a.sample_rate))

    result = DataFrame(
                        ID                  = ID,
                        AnalysisFrequency   = freq_of_interest,
                        ModulationFrequency = float(a.modulation_frequency),
                        ChannelOrigin       = copy(a.channel_names[ChannelOrigin]),
                        ChannelDestination  = copy(a.channel_names[ChannelDestination]),
                        AnalysisType        = "phase_lag_index",
                        Strength            = pli
                      )

    result = add_dataframe_static_rows(result, kwargs)

    key_name = new_processing_key(a.processing, "pli")
    merge!(a.processing, [key_name => result])

    return a
end


# If you want multiple frequencies analyse each one in turn
function phase_lag_index(a::SSR, ChannelOrigin::Int, ChannelDestination::Int, freq_of_interest::AbstractArray; kwargs...)

    for f in freq_of_interest
        a = phase_lag_index(a, ChannelOrigin, ChannelDestination, freq_of_interest=f; kwargs...)
    end

    return a
end


# If you dont specify an analysis frequency, use modulation frequency
function phase_lag_index(a::SSR, ChannelOrigin::Int, ChannelDestination::Int;
        freq_of_interest::Union(Real, AbstractArray)=[float(a.modulation_frequency)],
        ID::String="", kwargs...)
    phase_lag_index(a, ChannelOrigin, ChannelDestination, freq_of_interest, ID=ID; kwargs...)
end


# Analyse between two sensors by name
function phase_lag_index(a::SSR, ChannelOrigin::String, ChannelDestination::String; kwargs... )

    ChannelOrigin =      int(findfirst(a.channel_names, ChannelOrigin))
    ChannelDestination = int(findfirst(a.channel_names, ChannelDestination))

    debug("Converted channel names to indices $ChannelOrigin $ChannelDestination")

    a = phase_lag_index(a, ChannelOrigin, ChannelDestination, freq_of_interest, ID=ID; kwargs... )

end


# Analyse list of sensors provided by index
function phase_lag_index(a::SSR, ChannelOrigin::Array{Int}; kwargs...)

    for i = 1:length(ChannelOrigin)-1
        for j = i+1:length(ChannelOrigin)
            a = phase_lag_index(a, ChannelOrigin[i], ChannelOrigin[j]; kwargs...)
        end
    end

    return a
end


# Analyse list of sensors provided by name
function phase_lag_index(a::SSR, ChannelOrigin::Array{ASCIIString}; kwargs...)

    idxs = [int(findfirst(a.channel_names, co)) for co in ChannelOrigin]

    phase_lag_index(a, idxs; kwargs...)
end


# Analyse all sensors
function phase_lag_index(a::SSR; kwargs... )

    phase_lag_index(a, a.channel_names; kwargs...)
end



#
# Save results
#

# Save synchrony results to file
function save_synchrony_results(a::SSR; name_extension::String="-synchrony", kwargs...)

    file_name = string(a.file_name, name_extension, ".csv")

    # Rename to save space
    results = a.processing

    # Index of keys to be exported
    result_idx = find_keys_containing(results, "pli")

    debug("Found $(length(result_idx)) synchrony results")

    if length(result_idx) > 0

        to_save = get(results, collect(keys(results))[result_idx[1]], 0)

        if length(result_idx) > 1
            for k = result_idx[2:end]
                result_data = get(results, collect(keys(results))[k], 0)
                to_save = rbind(to_save, result_data)
            end
        end

    writetable(file_name, to_save)
    end

    info("File saved to $file_name")

    return a
end


#######################################
#
# Helper functions
#
#######################################


function assr_frequency(rounded_freq::Number; stimulation_sample_rate::Number=32000,
                        stimulation_frames_per_epoch::Number=32768)

    round(rounded_freq/(stimulation_sample_rate / stimulation_frames_per_epoch)) *
                                                                stimulation_sample_rate / stimulation_frames_per_epoch
end

function assr_frequency(rounded_freq::AbstractVector)

    [assr_frequency(f) for f = rounded_freq]
end


