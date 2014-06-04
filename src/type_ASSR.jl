using JBDF


type ASSR
    data::Array
    labels::Array{String}
    triggers::Dict
    header::Dict
    processing::Dict
    modulation_frequency::Number
    reference_channel::String
end


function read_EEG(fname::String; verbose::Bool=false)

    # Import using JBDF
    dats, evtTab, trigChan, sysCodeChan = readBdf(fname)
    bdfInfo = readBdfHeader(fname)

    if verbose
        println("Imported $(size(dats)[1]) ASSR channels")
    end

    # Place in type
    eeg = ASSR(dats', bdfInfo["chanLabels"], evtTab, bdfInfo, Dict(), NaN, "Raw")

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
    key_name = "filter"
    key_numb = 1
    key = string(key_name, key_numb)
    while haskey(eeg.processing, key)
        key_numb += 1
        key = string(key_name, key_numb)
    end
    merge!(eeg.processing, [key => f])

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

    snr_result = Array(Float64, (1,size(eeg.data)[end]))
    signal     = Array(Float64, (1,size(eeg.data)[end]))
    noise      = Array(Float64, (1,size(eeg.data)[end]))
    statistic  = Array(Float64, (1,size(eeg.data)[end]))

    # Extract required information
    fs = eeg.header["sampRate"][1]

    if haskey(eeg.processing, "filter1")
        used_filter = eeg.processing["filter1"]
    else
        used_filter = nothing
    end

    if verbose
        println("Calculating F statistic on $(size(eeg.data)[end]) channels")
        p = Progress(size(eeg.data)[end], 1, "  F-test...    ", 50)
    end

    for chan = 1:size(eeg.data)[end]

        snr_result[chan], signal[chan], noise[chan] = ftest(eeg.processing["sweeps"][:,:,chan],
                                                            freq_of_interest,
                                                            fs,
                                                            verbose     = false,
                                                            side_freq   = side_freq,
                                                            used_filter = used_filter)
        if verbose; next!(p); end
    end

    results = [ "SNRdB"        => snr_result,
                "signal_power" => signal,
                "noise_power"  => noise,
                "statistic"    => statistic,
                "frequency"    => freq_of_interest,
                "bins"         => side_freq]

    merge!(eeg.processing, [string("ftest-",freq_of_interest) => results])

    if verbose
        println("")
    end

    return eeg
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

    # If F test has been run then report those values
    if targetFreq != 0
        try
            result_snr = round(eeg.processing[string("ftest-", targetFreq)]["SNRdB"][chan], 2)
            title  = "Channel $(channel_name). SNR = $(result_snr) dB"
            noise  = eeg.processing[string("ftest-", targetFreq)]["noise_power"][chan]
            signal = eeg.processing[string("ftest-", targetFreq)]["signal_power"][chan]
        catch
            println("!! Frequency you requested statistics for was not available. Did you calculate it?")
            title  = "Channel $(channel_name)"
            noise  = 0
            signal = 0
        end
    else # You didn't ask for a specific frequency to look at
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


#######################################
#
# Helper functions
#
#######################################


function _decode_processing_name(name::String)

    known_processes = ["filter, ftest, sweeps, epochs"]

end


function append_strings(strings::Array{ASCIIString}; separator::String=" ")

    newString = strings[1]
    if length(strings) > 1
        for n = 2:length(strings)
            newString = string(newString, separator, strings[n])
        end
    end

    return newString
end


function append_strings(strings::String; separator::String=" ")

    return strings
end
