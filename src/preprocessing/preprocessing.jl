# Processing functions
#
# highpass_filter                    # High pass filter
# remove_template            # Removes a template signal from each channel
# rereference             # Re reference
# proc_epochs                # Extract epochs
# proc_epoch_rejection       # Reject epochs
# proc_sweeps                # Create sweeps
# proc_ftest                 # F test
#
# _find_frequency_idx
#


using DataFrames
using DSP
using ProgressMeter
using Distributions


#######################################
#
# High pass filter
#
#######################################

function highpass_filter(signals::Array; cutOff::Number=2,
                         order::Int=3, fs::Int=8192, verbose::Bool=false)

    signals = convert(Array{Float64}, signals)

    Wn = cutOff/(fs/2)
    f = digitalfilter(Highpass(Wn), Butterworth(order))

    if verbose
        println("Highpass filtering $(size(signals)[end]) channels")
        println("  Pass band > $(cutOff) Hz")
        p = Progress(size(signals)[end], 1, "  Filtering... ", 50)
    end

    chan = 1
    while chan <= size(signals)[end]
        signals[:, chan] = filt(f, vec(signals[:, chan]))
        signals[:, chan] = flipud(signals[:, chan])
        signals[:, chan] = filt(f, vec(signals[:, chan]))
        signals[:, chan] = flipud(signals[:, chan])
        if verbose; next!(p); end
        chan += 1
    end

    return signals, f
end


##########################################
#
# Remove template signal from all channels
#
##########################################

# Pass in array to subtract from each channel
function remove_template(signals::Array,
                        reference::Array;  # TODO: Make an array of generic floats
                        verbose::Bool=false)

    if verbose; p = Progress(size(signals)[end], 1, "  Rerefing...  ", 50); end

    for chan = 1:size(signals)[end]
        signals[:, chan] = signals[:, chan] - reference
        if verbose; next!(p); end
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
                        refChan::Array{Int};
                        verbose::Bool=false)

    if verbose
        if length(refChan) == 1
            println("Re referencing $(size(signals)[end]) channels to channel $(refChan[1])")
        else
            println("Re referencing $(size(signals)[end]) channels to the mean of $(length(refChan)) channels")
        end
    end

    reference_signal = mean(signals[:, refChan],2)

    return remove_template(signals, reference_signal, verbose=verbose)
end

# Rewrap as array
function rereference(signals::Array, refChan::Int; verbose::Bool=false)
    return rereference(signals, [refChan], verbose=verbose)
end

# Pass in name of channels to re reference to
function rereference(signals::Array,
                        refChan::Union(String, Array{ASCIIString}),
                        chanNames::Array{String};
                        verbose::Bool=false)


    if refChan == "car" || refChan == "average"
        refChan_Idx = [1:size(signals)[end]]
    elseif isa(refChan, String)
        refChan_Idx = findfirst(chanNames, refChan)
    elseif (isa(refChan, Array))
        refChan_Idx = [findfirst(chanNames, i) for i = refChan]
    end

    if verbose
        println("Re referencing $(size(signals)[end]) channels to channel $(append_strings(chanNames[refChan_Idx])) = $refChan_Idx ")
    end

    if refChan == 0; error("Requested channel is not in the provided list of channels"); end

    return rereference(signals, refChan_Idx, verbose=verbose)
end


#######################################
#
# Helper functions
#
#######################################

function _find_frequency_idx(freq_array::Array, freq_of_interest::Number;
                                verbose::Bool=false)

    diff_array = abs(freq_array .- freq_of_interest)
    targetIdx  = findfirst(diff_array , minimum(diff_array))

    if verbose
        println("Frequency index is $(targetIdx) is $(freq_array[targetIdx]) Hz")
    end

    return targetIdx
end

