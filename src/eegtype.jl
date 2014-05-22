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

    return eeg
 end


function proc_reference(eeg::EEG, refChan::String; verbose::Bool=false)

    eeg.data = proc_reference(eeg.data, refChan, eeg.labels, verbose=verbose)

    return eeg
end


