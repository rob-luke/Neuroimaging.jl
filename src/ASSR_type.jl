using JBDF


type ASSR
    data::Array
    labels::Array{String}
    triggers::Dict
    header::Dict
    processing::Dict
end


function read_EEG(fname::String; verbose::Bool=false)

    # Import using JBDF
    dats, evtTab, trigChan, sysCodeChan = readBdf(fname)
    bdfInfo = readBdfHeader(fname)

    # Place in type
    eeg = ASSR(dats', bdfInfo["chanLabels"], evtTab, bdfInfo, Dict())

    # Tidy channel names if required
    if bdfInfo["chanLabels"][1] == "A1"
        if verbose
            println("Converting ASSR channel names")
        end
        eeg.labels = channelNames_biosemi_1020(eeg.labels)
    end

    if verbose
        println("Imported $(size(eeg.data)[end]) ASSR channels")
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

    return eeg
 end


function proc_reference(eeg::ASSR, refChan::String; verbose::Bool=false)

    eeg.data = proc_reference(eeg.data, refChan, eeg.labels, verbose=verbose)

    #TODO: Record the reference channel somewhere

    return eeg
end


function extract_epochs(eeg::ASSR; verbose::Bool=false)

    merge!(eeg.processing, ["epochs" => extract_epochs(eeg.data, eeg.triggers, verbose=verbose)])

    #=eeg.processing["epochs"] = eeg.processing["epochs"][:,3:end,:]=#

    return eeg
end


function create_sweeps(eeg::ASSR; epochsPerSweep::Int=4, verbose::Bool=false)

    merge!(eeg.processing, 
        ["sweeps" => create_sweeps(eeg.processing["epochs"], epochsPerSweep = epochsPerSweep, verbose = verbose)])

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

    if verbose
        println("Calculating F statistic on $(size(eeg.data)[end]) channels")
        p = Progress(size(eeg.data)[end], 1, "  F-test...    ", 50)
    end

    for chan = 1:size(eeg.data)[end]
    
        snr_result[chan], signal[chan], noise[chan] = ftest(eeg.processing["sweeps"][:,:,chan],  
                                                            freq_of_interest,
                                                            eeg.header["sampRate"][1],
                                                            verbose     = false,
                                                            side_freq   = side_freq,
                                                            used_filter = eeg.processing["filter1"])

        if verbose; next!(p); end
    end

    results = [ "SNRdB"        => snr_result,
                "signal_power" => signal,
                "noise_power"  => noise,
                "statistic"    => statistic,
                "frequency"    => freq_of_interest,
                "bins"         => side_freq]

    merge!(eeg.processing, [string("ftest-",freq_of_interest) => results])

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
