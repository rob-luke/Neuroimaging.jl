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


function add_channel(eeg::ASSR, data::Array, chanLabels::ASCIIString;
                     sampRate::Int=0,        physMin::Int=0,          physMax::Int=0, scaleFactor::Int=0,
                     digMax::Int=0,          digMin::Int=0,           nSampRec::Int=0,
                     prefilt::String="",     reserved::String="",     physDim::String="",
                     transducer::String="")

    info("Adding channel $chanLabels")

    eeg.data = hcat(eeg.data, data)

    push!(eeg.header["sampRate"],    sampRate    == 0 ? eeg.header["sampRate"][1]    : sampRate)
    push!(eeg.header["physMin"],     physMin     == 0 ? eeg.header["physMin"][1]     : physMin)
    push!(eeg.header["physMax"],     physMax     == 0 ? eeg.header["physMax"][1]     : physMax)
    push!(eeg.header["digMax"],      digMax      == 0 ? eeg.header["digMax"][1]      : digMax)
    push!(eeg.header["digMin"],      digMin      == 0 ? eeg.header["digMin"][1]      : digMin)
    push!(eeg.header["nSampRec"],    nSampRec    == 0 ? eeg.header["nSampRec"][1]    : nSampRec)
    push!(eeg.header["scaleFactor"], scaleFactor == 0 ? eeg.header["scaleFactor"][1] : scaleFactor)

    push!(eeg.header["prefilt"],    prefilt    == "" ? eeg.header["prefilt"][1]    : prefilt)
    push!(eeg.header["reserved"],   reserved   == "" ? eeg.header["reserved"][1]   : reserved)
    push!(eeg.header["chanLabels"], chanLabels == "" ? eeg.header["chanLabels"][1] : chanLabels)
    push!(eeg.header["transducer"], transducer == "" ? eeg.header["transducer"][1] : transducer)
    push!(eeg.header["physDim"],    physDim    == "" ? eeg.header["physDim"][1]    : physDim)


    return eeg
end

function trim_ASSR(eeg::ASSR, stop::Int; start::Int=1)

    info("Trimming $(size(eeg.data)[end]) channels between $start and $stop")

    eeg.data = eeg.data[start:stop,:]
    eeg.sysCodeChan = eeg.sysCodeChan[start:stop]
    eeg.trigChan = eeg.trigChan[start:stop]


    to_keep = find(eeg.triggers["idx"] .<= stop)
    eeg.triggers["idx"]  = eeg.triggers["idx"][to_keep]
    eeg.triggers["dur"]  = eeg.triggers["dur"][to_keep]
    eeg.triggers["code"] = eeg.triggers["code"][to_keep]

    return eeg
end


function remove_channel!(eeg::ASSR, channel_idx::Int)

    info("Removing channel $channel_idx")

    keep_idx = [1:size(eeg.data)[end]]
    try
        splice!(keep_idx, channel_idx)
    end

    eeg.data = eeg.data[:, keep_idx]

    # Remove header info that is for each channel
    # TODO: Put in loop
    eeg.header["sampRate"]    = eeg.header["sampRate"][keep_idx]
    eeg.header["physMin"]     = eeg.header["physMin"][keep_idx]
    eeg.header["physMax"]     = eeg.header["physMax"][keep_idx]
    eeg.header["nSampRec"]    = eeg.header["nSampRec"][keep_idx]
    eeg.header["prefilt"]     = eeg.header["prefilt"][keep_idx]
    eeg.header["reserved"]    = eeg.header["reserved"][keep_idx]
    eeg.header["chanLabels"]  = eeg.header["chanLabels"][keep_idx]
    eeg.header["transducer"]  = eeg.header["transducer"][keep_idx]
    eeg.header["physDim"]     = eeg.header["physDim"][keep_idx]
    eeg.header["digMax"]      = eeg.header["digMax"][keep_idx]
    eeg.header["digMin"]      = eeg.header["digMin"][keep_idx]
    eeg.header["scaleFactor"] = eeg.header["scaleFactor"][keep_idx]


    return eeg
end

function remove_channel!(eeg::ASSR, channel_idxs::AbstractVector)

    info("Removing channels $channel_idxs")

    # Remove channels with highest index first so other indicies arent altered
    channel_idxs = sort([channel_idxs], rev=true)

    for channel = channel_idxs
        eeg = remove_channel!(eeg, channel)
    end

    return eeg
end

function remove_channel!(eeg::ASSR, channel_name::String)

    info("Removing channel $channel_name")

    remove_channel!(eeg, findfirst(eeg.header["chanLabels"], channel_name))
end

function remove_channel!(eeg::ASSR, channel_names::Array{ASCIIString})

    info("Removing channels $(append_strings(channel_names))")

    for channel = channel_names
        eeg = remove_channel!(eeg, channel)
    end

    return eeg
end


function merge_channels(eeg::ASSR, merge_Chans::Array{ASCIIString}, new_name::String)

    keep_idxs = [findfirst(eeg.header["chanLabels"], i) for i = merge_Chans]
    keep_idxs = int(keep_idxs)

    info("Merging channels $(append_strings(vec(eeg.header["chanLabels"][keep_idxs,:])))")
    info("Merging channels $(keep_idxs)")

    eeg = add_channel(eeg, mean(eeg.data[:,keep_idxs], 2), new_name)
end




function highpass_filter(eeg::ASSR; cutOff::Number=2, order::Int=3, t::Int=3)

    eeg.data, f = highpass_filter(eeg.data, cutOff=cutOff, order=order, fs=eeg.header["sampRate"][1])

    # Save the filter settings as a unique key in the processing dict
    # This allows for applying multiple filters and tracking them all
    key_name = new_processing_key(eeg.processing, "filter")
    merge!(eeg.processing, [key_name => f])

    # Remove adaptation period
    eeg.data = eeg.data[t*8192:end-t*8192, :]
    eeg.triggers["idx"] = eeg.triggers["idx"] .- 2*t*8192
    # And ensure the triggers are still in sync
    to_keep = find(eeg.triggers["idx"] .>= 0)
    eeg.triggers["idx"]  = eeg.triggers["idx"][to_keep]
    eeg.triggers["dur"]  = eeg.triggers["dur"][to_keep]
    eeg.triggers["code"] = eeg.triggers["code"][to_keep]
    # Remove sysCode
    eeg.sysCodeChan = eeg.sysCodeChan[t*8192:end-t*8192]

    return eeg
 end


function rereference(eeg::ASSR, refChan)

    eeg.data = rereference(eeg.data, refChan, eeg.header["chanLabels"])

    if isa(refChan, Array)
        refChan = append_strings(refChan)
    end

    eeg.reference_channel = refChan

    return eeg
end


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

function ftest(eeg::ASSR; side_freq::Number=2)

    eeg = ftest(eeg, eeg.modulation_frequency-1, side_freq=side_freq)
    eeg = ftest(eeg, eeg.modulation_frequency,   side_freq=side_freq)
    eeg = ftest(eeg, eeg.modulation_frequency+1, side_freq=side_freq)
    eeg = ftest(eeg, eeg.modulation_frequency*2, side_freq=side_freq)
    eeg = ftest(eeg, eeg.modulation_frequency*3, side_freq=side_freq)
    eeg = ftest(eeg, eeg.modulation_frequency*4, side_freq=side_freq)

    return eeg
end

function ftest(eeg::ASSR, freq_of_interest::Number; side_freq::Number=2)

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
                        Electrode = eeg.header["chanLabels"],
                        SignalPower = vec(signal),
                        NoisePower = vec(noise),
                        SNR = vec(10.^(snrDb/10)),
                        SNRdB = vec(snrDb),
                        Statistic = vec(statistic),
                        Significant = vec(statistic.<0.05),
                        Subject = "Unknown",
                        Analysis="ftest",
                        NoiseHz = side_freq,
                        Frequency = freq_of_interest,
                        ModulationFrequency = eeg.modulation_frequency,
                        PresentationAmplitude = eeg.amplitude
                        )

    key_name = new_processing_key(eeg.processing, "ftest")
    merge!(eeg.processing, [key_name => result])

    return eeg
end

function ftest(eeg::ASSR, freq_of_interest::Array; side_freq::Number=2)

    for f = freq_of_interest
        eeg = ftest(eeg, f, side_freq=side_freq)
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


