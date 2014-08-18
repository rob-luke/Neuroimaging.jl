using BDF
using DataFrames
using MAT


type ASSR
    data::Array
    triggers::Dict   #TODO: Change to events
    header::Dict
    processing::Dict
    modulation_frequency::Number
    amplitude::Number
    reference_channel::String
    file_path::String
    file_name::String
    sysCodeChan
    trigChan          #TODO: Change to tiggers
end


#######################################
#
# Read ASSR
#
#######################################

function read_ASSR(fname::Union(String, IO))

    info("Importing file $fname")

    # Import using JBDF
    fname2 = copy(fname)
    dats, evtTab, trigChan, sysCodeChan = readBDF(fname)
    bdfInfo = readBDFHeader(fname)

    filepath, filename, ext = fileparts(bdfInfo["fileName"])

    # Check if matching mat file exists
    mat_path = string(filepath, filename, ".mat")
    if isreadable(mat_path)
        rba = matread(mat_path)
        modulation_frequency = rba["properties"]["stimulation_properties"]["stimulus_1"]["rounded_modulation_frequency"]
        amplitude = rba["properties"]["stimulation_properties"]["stimulus_1"]["amplitude"]
        info("Imported matching .mat file")
    else
        modulation_frequency = NaN
        amplitude = NaN
    end

    # Place in type
    eeg = ASSR(dats', evtTab, bdfInfo, Dict(), modulation_frequency, amplitude, "Raw", filepath, filename, sysCodeChan, trigChan)

    remove_channel!(eeg, "Status")

    debug("  Imported $(size(dats)[1]) ASSR channels")
    debug("  Info: $(eeg.modulation_frequency)Hz, $(eeg.header["subjID"]), $(eeg.header["startDate"]), $(eeg.header["startTime"])")

    # Tidy channel names if required
    if bdfInfo["chanLabels"][1] == "A1"
        debug("  Converting names from BIOSEMI to 10-20")
        eeg.header["chanLabels"] = channelNames_biosemi_1020(eeg.header["chanLabels"])
    end

    return eeg
end


#######################################
#
# Modify ASSR
#
#######################################

function add_channel(eeg::ASSR, data::Array, chanLabels::ASCIIString;
                     sampRate::Number=eeg.header["sampRate"][1],     scaleFactor::Number=eeg.header["scaleFactor"][1],
                     physMin::Number=eeg.header["physMin"][1],       physMax::Number=eeg.header["physMax"][1],
                     digMin::Number=eeg.header["digMin"][1],         digMax::Number=eeg.header["digMax"][1],
                     nSampRec::Number=eeg.header["nSampRec"][1],     prefilt::String=eeg.header["prefilt"][1],
                     reserved::String=eeg.header["reserved"][1],     physDim::String=eeg.header["physDim"][1],
                     transducer::String=eeg.header["transducer"][1])

    info("Adding channel $chanLabels")

    eeg.data = hcat(eeg.data, data)

    push!(eeg.header["sampRate"],    sampRate)
    push!(eeg.header["physMin"],     physMin)
    push!(eeg.header["physMax"],     physMax)
    push!(eeg.header["digMax"],      digMax)
    push!(eeg.header["digMin"],      digMin)
    push!(eeg.header["nSampRec"],    nSampRec)
    push!(eeg.header["scaleFactor"], scaleFactor)

    push!(eeg.header["prefilt"],    prefilt)
    push!(eeg.header["reserved"],   reserved)
    push!(eeg.header["chanLabels"], chanLabels)
    push!(eeg.header["transducer"], transducer)
    push!(eeg.header["physDim"],    physDim)

    return eeg
end


function remove_channel!(eeg::ASSR, channel_idx::Array{Int})

    channel_idx = channel_idx[channel_idx .!= 0]

    info("Removing channel(s) $channel_idx")

    keep_idx = [1:size(eeg.data)[end]]
    for c = sort(channel_idx, rev=true)
        try
            splice!(keep_idx, c)
        end
    end

    eeg.data = eeg.data[:, keep_idx]

    # Remove header info
    for key = ["sampRate", "physMin", "physMax", "nSampRec", "prefilt", "reserved", "chanLabels", "transducer",
               "physDim", "digMax", "digMin", "scaleFactor"]
        eeg.header[key]    = eeg.header[key][keep_idx]
    end
end

function remove_channel!(eeg::ASSR, channel_names::Array{ASCIIString})

    info("Removing channel(s) $(append_strings(channel_names))")

    remove_channel!(eeg, int([findfirst(eeg.header["chanLabels"], c) for c=channel_names]))
end

function remove_channel!(eeg::ASSR, channel_name::Union(String, Int))
    remove_channel!(eeg, [channel_name])
end


function trim_ASSR(eeg::ASSR, stop::Int; start::Int=1)

    info("Trimming $(size(eeg.data)[end]) channels between $start and $stop")

    eeg.data = eeg.data[start:stop,:]
    eeg.sysCodeChan = eeg.sysCodeChan[start:stop]
    eeg.trigChan = eeg.trigChan[start:stop]


    to_keep = find(eeg.triggers["idx"] .<= stop)
    eeg.triggers["idx"]  = eeg.triggers["idx"][to_keep]
    #=eeg.triggers["dur"]  = eeg.triggers["dur"][to_keep]=#
    eeg.triggers["code"] = eeg.triggers["code"][to_keep]

    return eeg
end


#######################################
#
# Merge channels
#
#######################################

function merge_channels(eeg::ASSR, merge_Chans::Array{ASCIIString}, new_name::String)

    debug("Total origin channels: $(length(eeg.header["chanLabels"]))")

    keep_idxs = [findfirst(eeg.header["chanLabels"], i) for i = merge_Chans]
    keep_idxs = int(keep_idxs)

    if sum(keep_idxs .== 0) > 0
        warn("Could not merge channels as don't exist: $(append_strings(vec(merge_Chans[keep_idxs .== 0])))")
        keep_idxs = keep_idxs[keep_idxs .> 0]
    end

    info("Merging channels $(append_strings(vec(eeg.header["chanLabels"][keep_idxs,:])))")
    debug("Merging channels $keep_idxs")

    eeg = add_channel(eeg, mean(eeg.data[:,keep_idxs], 2), new_name)
end


#######################################
#
# Filtering
#
#######################################


function highpass_filter(eeg::ASSR; cutOff::Number=2, order::Int=3, tolerance::Number=0.01)

    eeg.data, f = highpass_filter(eeg.data, cutOff=cutOff, order=order, fs=eeg.header["sampRate"][1])

    _filter_check(f, eeg.modulation_frequency, eeg.header["sampRate"][1], tolerance)

    return _append_filter(eeg, f)
 end


function lowpass_filter(eeg::ASSR; cutOff::Number=150, order::Int=3, tolerance::Number=0.01)

    eeg.data, f = lowpass_filter(eeg.data, cutOff=cutOff, order=order, fs=eeg.header["sampRate"][1])

    _filter_check(f, eeg.modulation_frequency, eeg.header["sampRate"][1], tolerance)

    return _append_filter(eeg, f)
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


function _append_filter(eeg::ASSR, f::Filter; name::String="filter")
    #
    # Put the filter information in the ASSR processing structure
    #

    key_name = new_processing_key(eeg.processing, "filter")
    merge!(eeg.processing, [key_name => f])

    return eeg
end


#######################################
#
# filtering
#
#######################################

function rereference(eeg::ASSR, refChan)

    eeg.data = rereference(eeg.data, refChan, eeg.header["chanLabels"])

    if isa(refChan, Array)
        refChan = append_strings(refChan)
    end

    eeg.reference_channel = refChan

    return eeg
end


#######################################
#
# Add triggers for more epochs
#
#######################################


function add_triggers(a::ASSR;
                      cycle_per_epoch::Int=1, remove_first::Int=0, max_epochs::Number=Inf)

    add_triggers(a, a.modulation_frequency, cycle_per_epoch=cycle_per_epoch)
end


function add_triggers(a::ASSR, mod_freq::Float64;
                      cycle_per_epoch::Int=1, remove_first::Int=0, max_epochs::Number=Inf)


    epochIndex = _clean_epoch_index(a, remove_first=remove_first, max_epochs=max_epochs)

    add_triggers(a, a.modulation_frequency, epochIndex, cycle_per_epoch=cycle_per_epoch)
end


function add_triggers(a::ASSR, mod_freq::Number, epochIndex;
                      cycle_per_epoch::Int=1, max_epochs::Number=Inf)

    info("Adding triggers to reduce to $cycle_per_epoch cycle.")

    # Existing epochs
    existing_epoch_length   = maximum(diff(epochIndex[:Index]))     # samples
    existing_epoch_length_s = existing_epoch_length / a.header["sampRate"][1]
    debug("Existing epoch length: $(existing_epoch_length_s)s")

    # New epochs
    new_epoch_length_s = cycle_per_epoch / mod_freq
    new_epochs_num     = round(existing_epoch_length_s / new_epoch_length_s) - 2
    new_epoch_times    = [1:new_epochs_num]*new_epoch_length_s
    new_epoch_indx     = [0, round(new_epoch_times * a.header["sampRate"][1])]

    debug("new epoch length = $new_epoch_length_s")
    debug("num epochs       = $new_epochs_num")
    debug("max time         = $(maximum(new_epoch_times))")

    debug("was $(length(epochIndex[:Index])) indices")

    # Place new epoch indices
    new_indx = epochIndex[:Index][1:end-1] .+ new_epoch_indx'
    new_indx = reshape(new_indx', length(new_indx), 1)[1:end-1]

    debug("now $(length(new_indx)) indices")

    # Place in dict
    # Will wipe old info
    new_code = int(ones(1, length(new_indx))) .+ 252
    a.triggers = ["idx" => vec(int(new_indx)'), "code" => vec(new_code)]

    return a
end


function _clean_epoch_index(a::ASSR; remove_first::Int=0, max_epochs::Number=Inf, valid_indices::Array{Int}=[1, 2])

    # Make in to data frame for easy management
    epochIndex = DataFrame(Code = a.triggers["code"], Index = a.triggers["idx"]);

    # Make the codes more readable
    epochIndex[:Code] = epochIndex[:Code] - 252

    # Check for not valid indices and throw a warning
    if sum([in(i, [0, valid_indices]) for i = epochIndex[:Code]]) != length(epochIndex[:Code])
        non_valid = !convert(Array{Bool}, [in(i, [0, valid_indices]) for i = epochIndex[:Code]])
        non_valid = unique(epochIndex[:Code][non_valid])
        warn("File contains non valid triggers: $non_valid")
        debug(epochIndex)
    end

    # Just take valid indices
    valid = convert(Array{Bool}, vec([in(i, valid_indices) for i = epochIndex[:Code]]))
    epochIndex = epochIndex[ valid , : ]

    # How long are the indices
    epochIndex[:Length] = [0, diff(epochIndex[:Index])]

    # Trim values if requested
    epochIndex = epochIndex[remove_first+1:end,:]                                  # Often the first trigger is rubbish
    epochIndex = epochIndex[1:minimum([max_epochs, length(epochIndex[:Index])]),:] # If there is rubbish at the end

    # Sanity check
    if std(epochIndex[:Length]) > 1
        warn("Your epoch lengths vary too much")
        warn("Length: median=$(median(epochIndex[:Length])) sd=$(std(epochIndex[:Length])) min=$(minimum(epochIndex[:Length]))")
        debug(epochIndex)
    end

    debug("Existing epochs: $(length(epochIndex[:Index]))")

    return epochIndex
end




#######################################
#
# Extract epochs
#
#######################################

function extract_epochs(eeg::ASSR)

    merge!(eeg.processing, ["epochs" => extract_epochs(eeg.data, eeg.triggers)])


    return eeg
end


function create_sweeps(eeg::ASSR; epochsPerSweep::Int=4)

    merge!(eeg.processing,
        ["sweeps" => create_sweeps(eeg.processing["epochs"], epochsPerSweep = epochsPerSweep)])

    return eeg
end


function write_ASSR(eeg::ASSR, fname::String)

    info("Saving $(size(eeg.data)[end]) channels to $fname")

    writeBDF(fname, eeg.data', eeg.trigChan, eeg.sysCodeChan, eeg.header["sampRate"][1],
        startDate=eeg.header["startDate"], startTime=eeg.header["startTime"],
        chanLabels=eeg.header["chanLabels"] )

end


#######################################
#
# Statistics
#
#######################################

function ftest(eeg::ASSR; side_freq::Number=2, subject::String="Unknown")

    ftest(eeg, eeg.modulation_frequency,   side_freq=side_freq, subject=subject)
end

function ftest(eeg::ASSR, freq_of_interest::Number; side_freq::Number=2, subject::String="Unknown")

    # Extract required information
    fs = eeg.header["sampRate"][1]

    # TODO: Account for multiple applied filters
    if haskey(eeg.processing, "filter1")
        used_filter = eeg.processing["filter1"]
    else
        used_filter = nothing
    end

    info("Calculating F statistic on $(size(eeg.data)[end]) channels at $freq_of_interest Hz +-$(side_freq) Hz")

    snrDb, signal, noise, statistic = ftest(eeg.processing["sweeps"], freq_of_interest, fs,
                                            side_freq = side_freq, used_filter = used_filter)

    result = DataFrame(
                        Electrode = copy(eeg.header["chanLabels"]),
                        SignalPower = vec(signal),
                        NoisePower = vec(noise),
                        SNR = vec(10.^(snrDb/10)),
                        SNRdB = vec(snrDb),
                        Statistic = vec(statistic),
                        Significant = vec(statistic.<0.05),
                        Subject = subject,
                        Analysis="ftest",
                        NoiseHz = side_freq,
                        Frequency = freq_of_interest,
                        ModulationFrequency = copy(eeg.modulation_frequency),
                        PresentationAmplitude = copy(eeg.amplitude)
                        )

    key_name = new_processing_key(eeg.processing, "ftest")
    merge!(eeg.processing, [key_name => result])

    return eeg
end

function ftest(eeg::ASSR, freq_of_interest::Array; side_freq::Number=2, subject::String="Unknown")

    for f = freq_of_interest
        eeg = ftest(eeg, f, side_freq=side_freq, subject=subject)
    end
    return eeg
end


function save_results(eeg::ASSR; name_extension::String="")

    file_name = string(eeg.file_name, name_extension, ".csv")

    # Rename to save space
    results = eeg.processing

    # Index of keys to be exported
    result_idx = find_keys_containing(results, "ftest")

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

    return eeg
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


