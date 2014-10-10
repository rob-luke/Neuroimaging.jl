using DataFrames
using ProgressMeter
using Distributions


##########################################
#
# Remove template signal from all channels
#
##########################################

# Pass in array to subtract from each channel
function remove_template(signals::Array,
                        reference::Array)


    for chan = 1:size(signals)[end]
        signals[:, chan] = signals[:, chan] - reference
    end

    return signals
end


#######################################
#
# Re reference
#
#######################################


# Pass in array of channels re reference to
function rereference(signals::Array,
                        refChan::Array{Int})

    info("Re referencing $(size(signals)[end]) channels to $(length(refChan)) channels")
    debug("Reference channels = $refChan")

    reference_signal = mean(signals[:, refChan],2)

    return remove_template(signals, reference_signal)
end

# Rewrap as array
function rereference(signals::Array, refChan::Int)
    return rereference(signals, [refChan])
end

# Pass in name of channels to re reference to
function rereference(signals::Array,
                        refChan::Union(String, Array{ASCIIString}),
                        chanNames::Array{String})


    if refChan == "car" || refChan == "average"
        refChan_Idx = [1:size(signals)[end]]
    elseif isa(refChan, String)
        refChan_Idx = findfirst(chanNames, refChan)
    elseif (isa(refChan, Array))
        refChan_Idx = [findfirst(chanNames, i) for i = refChan]
    end

    info("Re referencing $(size(signals)[end]) channels to $(length(refChan_Idx)) channels.")
    debug("Reference channels = $refChan")

    if refChan == 0; error("Requested channel is not in the provided list of channels"); end

    return rereference(signals, refChan_Idx)
end


#######################################
#
# Helper functions
#
#######################################

function _find_frequency_idx(freq_array::Array, freq_of_interest::Number)

    diff_array = abs(freq_array .- freq_of_interest)
    targetIdx  = findfirst(diff_array , minimum(diff_array))

    debug("Frequency index is $(targetIdx) is $(freq_array[targetIdx]) Hz")

    return targetIdx
end

