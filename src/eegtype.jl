using JBDF


type EEG
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
    eeg = EEG(dats, bdfInfo["chanLabels"], evtTab, bdfInfo, Dict())

    # Tidy channel names if required
    if bdfInfo["chanLabels"][1] == "A1"
        if verbose
            println("Converting EEG channel names")
        end
        eeg.labels = channelNames_biosemi_1020(eeg.labels)
    end

    if verbose
        println("Imported $(size(eeg.data)[1]) EEG channels")
    end

    return eeg
end


function proc_hp(eeg::EEG; cutOff::Number=2, order::Int=3, verbose::Bool=false)

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
    eeg.data = eeg.data[:, t*8192:end-t*8192]
    eeg.triggers["idx"] = eeg.triggers["idx"] .- 2*t*8192
    # And ensure the triggers are still in sync
    to_keep = find(eeg.triggers["idx"] .>= 0)
    eeg.triggers["idx"]  = eeg.triggers["idx"][to_keep]
    eeg.triggers["dur"]  = eeg.triggers["dur"][to_keep]
    eeg.triggers["code"] = eeg.triggers["code"][to_keep]

    return eeg
 end


function proc_reference(eeg::EEG, refChan::String; verbose::Bool=false)

    eeg.data = proc_reference(eeg.data, refChan, eeg.labels, verbose=verbose)

    return eeg
end


# Plot whole all data
function plot_timeseries(eeg::EEG; titletext::String="")

    p = plot_timeseries(eeg.data, eeg.header["sampRate"][1], titletext=titletext)

    return p
end

# Plot a single channel
function plot_timeseries(eeg::EEG, chanName::String; titletext::String="")

    idx = findfirst(eeg.labels, chanName)

    p = plot_timeseries(vec(eeg.data[idx,:]), eeg.header["sampRate"][1], titletext=titletext)

    return p
end
