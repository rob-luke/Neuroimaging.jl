using JBDF
using DataFrames


type ASSR
    data::Array
    labels::Array{String}
    triggers::Dict
    header::Dict
    processing::Dict
    modulation_frequency::Number
    reference_channel::String
    file_path::String
    file_name::String
end


function read_ASSR(fname::String; verbose::Bool=false)

    # Import using JBDF
    dats, evtTab, trigChan, sysCodeChan = readBdf(fname)
    bdfInfo = readBdfHeader(fname)

    if verbose
        println("Imported $(size(dats)[1]) ASSR channels")
    end

    filepath, filename, ext = fileparts(fname)

    # Place in type
    eeg = ASSR(dats', bdfInfo["chanLabels"], evtTab, bdfInfo, Dict(), NaN, "Raw", filepath, filename)

    # Tidy channel names if required
    if bdfInfo["chanLabels"][1] == "A1"
        if verbose
            println("  Converting names from BIOSEMI to 10-20")
        end
        eeg.labels = channelNames_biosemi_1020(eeg.labels)
    end

    if verbose
        println("")
    end

    return eeg
end


function proc_hp(eeg::ASSR; cutOff::Number=2, order::Int=3, verbose::Bool=false)

    eeg.data, f = proc_hp(eeg.data, cutOff=cutOff, order=order, fs=eeg.header["sampRate"][1], verbose=verbose)

    # Save the filter settings as a unique key in the processing dict
    # This allows for applying multiple filters and tracking them all
    key_name = new_processing_key(eeg.processing, "filter")
    merge!(eeg.processing, [key_name => f])

    # Remove adaptation period
    t = 3   #TODO: pass in as an argument?
    eeg.data = eeg.data[t*8192:end-t*8192, :]
    eeg.triggers["idx"] = eeg.triggers["idx"] .- 2*t*8192
    # And ensure the triggers are still in sync
    to_keep = find(eeg.triggers["idx"] .>= 0)
    eeg.triggers["idx"]  = eeg.triggers["idx"][to_keep]
    eeg.triggers["dur"]  = eeg.triggers["dur"][to_keep]
    eeg.triggers["code"] = eeg.triggers["code"][to_keep]

    if verbose
        println("")
    end

    return eeg
 end


function proc_reference(eeg::ASSR, refChan; verbose::Bool=false)

    eeg.data = proc_reference(eeg.data, refChan, eeg.labels, verbose=verbose)

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


#######################################
#
# Statistics
#
#######################################

function ftest(eeg::ASSR, freq_of_interest::Number; verbose::Bool=false, side_freq::Number=2)

    result = DataFrame(Subject=[], Frequency=[], Electrode=[], SignalPower=[], NoisePower=[], SNR=[], SNRdB=[],
                       Statistic=[], Significant=[], NoiseHz=[], Analysis=[])

    # Extract required information
    fs = eeg.header["sampRate"][1]

    # TODO: Account for multiple applied filters
    if haskey(eeg.processing, "filter1")
        used_filter = eeg.processing["filter1"]
    else
        used_filter = nothing
    end

    if verbose
        println("Calculating F statistic on $(size(eeg.data)[end]) channels at $freq_of_interest Hz")
        p = Progress(size(eeg.data)[end], 1, "  F-test...    ", 50)
    end

    for chan = 1:size(eeg.data)[end]

        snrDb, signal, noise, statistic = ftest(eeg.processing["sweeps"][:,:,chan], freq_of_interest, fs,
                                                verbose = false, side_freq = side_freq, used_filter = used_filter)

        new_result = DataFrame(Subject = "Unknown", Frequency = freq_of_interest, Electrode = eeg.labels[chan],
                               SignalPower = signal, NoisePower = noise, SNR = 10^(snrDb/10), SNRdB = snrDb,
                               Statistic = statistic, Significant = statistic<0.05, NoiseHz = side_freq,
                               Analysis="ftest")

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


function save_results(results::ASSR; name_extension::String="", verbose::Bool=true)

    file_name = string(results.file_name, name_extension, ".csv")

    # Rename to save space
    results = results.processing

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
end

#######################################
#
# Plotting
#
#######################################


# Plot whole all data
function plot_timeseries(eeg::ASSR; titletext::String="")

    p = plot_timeseries(eeg.data, eeg.header["sampRate"][1], titletext=titletext)

    return p
end

# Plot a single channel
function plot_timeseries(eeg::ASSR, chanName::String; titletext::String="")

    idx = findfirst(eeg.labels, chanName)

    p = plot_timeseries(vec(eeg.data[:, idx]), eeg.header["sampRate"][1], titletext=titletext)

    return p
end


function plot_spectrum(eeg::ASSR, chan::Int; targetFreq::Number=0)

    channel_name = eeg.labels[chan]

    # Check through the processing to see if we have done a statistical test at target frequency
    signal = nothing
    result_idx = find_keys_containing(eeg.processing, "ftest")

    for r = 1:length(result_idx)
        result = get(eeg.processing, collect(keys(eeg.processing))[result_idx[r]], 0)
        if result[:Frequency][1] == targetFreq

            result_snr = result[:SNRdB][chan]
            signal = result[:SignalPower][chan]
            noise  = result[:NoisePower][chan]
            title  = "Channel $(channel_name). SNR = $(result_snr) dB"
        end
    end

    if signal == nothing
        title  = "Channel $(channel_name)"
        noise  = 0
        signal = 0
    end

    p = plot_spectrum(convert(Array{Float64}, vec(mean(eeg.processing["sweeps"], 2)[:,chan])),
                        eeg.header["sampRate"][1];
                        titletext=title, targetFreq = targetFreq,
                        noise_level = noise, signal_level = signal)

    return p
end

function plot_spectrum(eeg::ASSR, chan::String; targetFreq::Number=0)

    return plot_spectrum(eeg, findfirst(eeg.labels, chan), targetFreq=targetFreq)
end

