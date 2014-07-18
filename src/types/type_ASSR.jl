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


function read_ASSR(fname::Union(String, IO); verbose::Bool=false)

    if verbose
        println("Importing file $fname")
    end

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
        if verbose
            println("  Imported matching .mat file")
        end
    else
        modulation_frequency = NaN
        amplitude = NaN
    end

    # Place in type
    eeg = ASSR(dats', evtTab, bdfInfo, Dict(), modulation_frequency, amplitude, "Raw", filepath, filename, sysCodeChan, trigChan)

    remove_channel!(eeg, "Status", verbose=true)

    if verbose
        println("  Imported $(size(dats)[1]) ASSR channels")
        println("  Info: $(eeg.modulation_frequency)Hz, $(eeg.header["subjID"]), $(eeg.header["startDate"]), $(eeg.header["startTime"])")
    end

    # Tidy channel names if required
    if bdfInfo["chanLabels"][1] == "A1"
        if verbose
            println("  Converting names from BIOSEMI to 10-20")
        end
        eeg.header["chanLabels"] = channelNames_biosemi_1020(eeg.header["chanLabels"])
    end

    if verbose
        println("")
    end

    return eeg
end


function add_channel(eeg::ASSR, data::Array, chanLabels::ASCIIString; verbose::Bool=false,
                     sampRate::Int=0,        physMin::Int=0,          physMax::Int=0, scaleFactor::Int=0,
                     digMax::Int=0,          digMin::Int=0,           nSampRec::Int=0,
                     prefilt::String="",     reserved::String="",     physDim::String="",
                     transducer::String="")

    if verbose
        println("Adding channel $chanLabels")
    end

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

function trim_ASSR(eeg::ASSR, stop::Int; start::Int=1, verbose::Bool=false)

    if verbose
        println("Trimming $(size(eeg.data)[end]) channels between $start and $stop")
    end

    eeg.data = eeg.data[start:stop,:]
    eeg.sysCodeChan = eeg.sysCodeChan[start:stop]
    eeg.trigChan = eeg.trigChan[start:stop]


    to_keep = find(eeg.triggers["idx"] .<= stop)
    eeg.triggers["idx"]  = eeg.triggers["idx"][to_keep]
    eeg.triggers["dur"]  = eeg.triggers["dur"][to_keep]
    eeg.triggers["code"] = eeg.triggers["code"][to_keep]


    return eeg
end


function remove_channel!(eeg::ASSR, channel_idx::Int; verbose::Bool=false)

    if verbose
        println("Removing channel $channel_idx")
    end

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

function remove_channel!(eeg::ASSR, channel_idxs::AbstractVector; verbose::Bool=false)

    if verbose
        println("Removing channels $channel_idxs")
        p = Progress(size(channel_idxs)[end], 1, "  Removing... ", 50)
    end

    # Remove channels with highest index first so other indicies arent altered
    channel_idxs = sort([channel_idxs], rev=true)

    for channel = channel_idxs
        eeg = remove_channel!(eeg, channel, verbose=false)
        if verbose; next!(p); end
    end

    return eeg
end

function remove_channel!(eeg::ASSR, channel_name::String; verbose::Bool=false)

    if verbose
        println("Removing channel $channel_name")
    end

    remove_channel!(eeg, findfirst(eeg.header["chanLabels"], channel_name), verbose=verbose)
end

function remove_channel!(eeg::ASSR, channel_names::Array{ASCIIString}; verbose::Bool=false)

    if verbose
        println("Removing channels $(append_strings(channel_names))")
        p = Progress(size(channel_names)[end], 1, "  Removing... ", 50)
    end

    for channel = channel_names
        eeg = remove_channel!(eeg, channel, verbose=false)
        if verbose; next!(p); end
    end

    return eeg
end


function merge_channels(eeg::ASSR, merge_Chans::Array{ASCIIString}, new_name::String; verbose::Bool=false)

    keep_idxs = [findfirst(eeg.header["chanLabels"], i) for i = merge_Chans]
    keep_idxs = int(keep_idxs)

    if verbose
        println("Merging channels $(append_strings(vec(eeg.header["chanLabels"][keep_idxs,:])))")
        println("Merging channels $(keep_idxs)")
    end

    eeg = add_channel(eeg, mean(eeg.data[:,keep_idxs], 2), new_name, verbose=verbose)
end




function highpass_filter(eeg::ASSR; cutOff::Number=2, order::Int=3, verbose::Bool=false, t::Int=3)

    eeg.data, f = highpass_filter(eeg.data, cutOff=cutOff, order=order, fs=eeg.header["sampRate"][1], verbose=verbose)

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

    if verbose
        println("")
    end

    return eeg
 end


function rereference(eeg::ASSR, refChan; verbose::Bool=false)

    eeg.data = rereference(eeg.data, refChan, eeg.header["chanLabels"], verbose=verbose)

    if isa(refChan, Array)
        refChan = append_strings(refChan)
    end

    eeg.reference_channel = refChan

    if verbose
        println("")
    end

    return eeg
end


function extract_epochs(eeg::ASSR; verbose::Bool=false)

    merge!(eeg.processing, ["epochs" => extract_epochs(eeg.data, eeg.triggers, verbose=verbose)])

    if verbose
        println("")
    end

    return eeg
end


function create_sweeps(eeg::ASSR; epochsPerSweep::Int=4, verbose::Bool=false)

    merge!(eeg.processing,
        ["sweeps" => create_sweeps(eeg.processing["epochs"], epochsPerSweep = epochsPerSweep, verbose = verbose)])

    if verbose
        println("")
    end

    return eeg
end


function write_ASSR(eeg::ASSR, fname::String; verbose::Bool=true)

    if verbose
        println("Saving $(size(eeg.data)[end]) channels to $fname")
    end

    writeBDF(fname, eeg.data', eeg.trigChan, eeg.sysCodeChan, eeg.header["sampRate"][1],
        startDate=eeg.header["startDate"], startTime=eeg.header["startTime"],
        chanLabels=eeg.header["chanLabels"] )

end


#######################################
#
# Statistics
#
#######################################

function ftest(eeg::ASSR; verbose::Bool=false, side_freq::Number=2)

    eeg = ftest(eeg, eeg.modulation_frequency-1, verbose=verbose, side_freq=side_freq)
    eeg = ftest(eeg, eeg.modulation_frequency,   verbose=verbose, side_freq=side_freq)
    eeg = ftest(eeg, eeg.modulation_frequency+1, verbose=verbose, side_freq=side_freq)
    eeg = ftest(eeg, eeg.modulation_frequency*2, verbose=verbose, side_freq=side_freq)
    eeg = ftest(eeg, eeg.modulation_frequency*3, verbose=verbose, side_freq=side_freq)
    eeg = ftest(eeg, eeg.modulation_frequency*4, verbose=verbose, side_freq=side_freq)

    return eeg
end

function ftest(eeg::ASSR, freq_of_interest::Number; verbose::Bool=false, side_freq::Number=2)

    result = DataFrame(Subject=[], Frequency=[], Electrode=[], SignalPower=[], NoisePower=[], SNR=[], SNRdB=[],
                       Statistic=[], Significant=[], NoiseHz=[], Analysis=[], ModulationFrequency=[],
                       PresentationAmplitude=[])

    # Extract required information
    fs = eeg.header["sampRate"][1]

    # TODO: Account for multiple applied filters
    if haskey(eeg.processing, "filter1")
        used_filter = eeg.processing["filter1"]
    else
        used_filter = nothing
    end

    if verbose
        println("Calculating F statistic on $(size(eeg.data)[end]) channels at $freq_of_interest Hz +-$(side_freq) Hz")
        p = Progress(size(eeg.data)[end], 1, "  F-test...    ", 50)
    end

    for chan = 1:size(eeg.data)[end]

        snrDb, signal, noise, statistic = ftest(eeg.processing["sweeps"][:,:,chan], freq_of_interest, fs,
                                                verbose = false, side_freq = side_freq, used_filter = used_filter)

        new_result = DataFrame(Subject = "Unknown", Frequency = freq_of_interest, Electrode = eeg.header["chanLabels"][chan],
                               SignalPower = signal, NoisePower = noise, SNR = 10^(snrDb/10), SNRdB = snrDb,
                               Statistic = statistic, Significant = statistic<0.05, NoiseHz = side_freq,
                               Analysis="ftest", ModulationFrequency = eeg.modulation_frequency,
                               PresentationAmplitude = eeg.amplitude)

        result = rbind(result, new_result)

        if verbose; next!(p); end
    end

    key_name = new_processing_key(eeg.processing, "ftest")
    merge!(eeg.processing, [key_name => result])

    if verbose
        println("")
    end

    return eeg
end

function ftest(eeg::ASSR, freq_of_interest::Array; verbose::Bool=false, side_freq::Number=2)

    for f = freq_of_interest
        eeg = ftest(eeg, f, verbose=verbose, side_freq=side_freq)
    end
    return eeg
end


function save_results(eeg::ASSR; name_extension::String="", verbose::Bool=true)

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

    if verbose
        println("File saved to $file_name")
    end

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


