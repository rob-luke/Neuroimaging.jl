# Processing functions
#
# proc_hp                    # High pass filter
# remove_template            # Removes a template signal from each channel
# proc_reference             # Re reference
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


#######################################
#
# High pass filter
#
#######################################

function proc_hp(signals::Array; cutOff::Number=2,
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
        signals[:, chan] = fliplr(signals[:, chan])
        signals[:, chan] = filt(f, vec(signals[:, chan]))
        signals[:, chan] = fliplr(signals[:, chan])
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
function proc_reference(signals::Array,
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
function proc_reference(signals::Array, refChan::Int; verbose::Bool=false)
    return proc_reference(signals, [refChan], verbose=verbose)
end

# Pass in name of channels to re reference to
function proc_reference(signals::Array,
                          refChan::String,
                          chanNames::Array{String};
                          verbose::Bool=false)

    if verbose
        println("Re referencing $(size(signals)[end]) channels to channel $refChan")
    end

    if refChan == "car" || refChan == "average"
        refChan = [1:size(signals)[end]]
    else
        refChan = findfirst(chanNames, refChan)
    end

    if refChan == 0; error("Requested channel is not in the provided list of channels"); end

    return proc_reference(signals, refChan, verbose=verbose)
end


#######################################
#
# Extract epochs
#
#######################################

function extract_epochs(dats::Array, evtTab::Dict; verbose::Bool=false)

    epochIndex = DataFrame(Code = evtTab["code"], Index = evtTab["idx"]);
    epochIndex = epochIndex[epochIndex[:Code].==252,:]
    epochIndex = epochIndex[epochIndex[:Code].==252,:]
    epochIndex = epochIndex[2:end,:]

    numEpochs = size(epochIndex)[1] - 1
    lenEpochs = minimum(diff(epochIndex[:Index]))
    numChans  = size(dats)[end]
    epochs = zeros(Float64, (lenEpochs, numEpochs, numChans))

    if verbose
        println("Generating epochs for $(numChans) channels")
        println("  Epoch length is $(lenEpochs)")
        println("  Number of epochs is $(numEpochs)")
        p = Progress(numChans, 1, "  Epoching...  ", 50)
    end

    chan = 1
    while chan <= numChans
        epoch = 1
        while epoch <= numEpochs

            startLoc = epochIndex[:Index][epoch]
            endLoc   = startLoc + lenEpochs - 1

            epochs[:,epoch, chan] = vec(dats[startLoc:endLoc, chan])

            epoch += 1
        end
        if verbose; next!(p); end
        chan += 1
    end

    return epochs
end


#######################################
#
# Reject epochs
#
#######################################

function proc_epoch_rejection(epochs::Array;
                    rejectionMethod::String="peak2peak", verbose::Bool=false)

    epochsLen = size(epochs)[1]
    epochsNum = size(epochs)[2]
    chansNum  = size(epochs)[3]

    if rejectionMethod == "peak2peak"

        peak2peak = Float64[]

        epoch = 1
        while epoch <= epochsNum

            push!(peak2peak, maximum(epochs[:,epoch,:]) - minimum(epochs[:,epoch,:]))

            epoch += 1
        end

        cutOff = sort(peak2peak)[floor(length(peak2peak)*0.9)]
        epochs = epochs[:, peak2peak.<cutOff, :]

    end

    return epochs
end


#######################################
#
# Create sweeps
#
#######################################

function create_sweeps(epochs::Array; epochsPerSweep::Int=4, verbose::Bool=false)

    epochsLen = size(epochs)[1]
    epochsNum = size(epochs)[2]
    chansNum  = size(epochs)[3]

    sweepLen = epochsLen * epochsPerSweep
    sweepNum = int(floor(epochsNum / epochsPerSweep))
    sweeps = zeros(Float64, (sweepLen, sweepNum, chansNum))

    if verbose
        println("Generating $(sweepNum) sweeps")
        println("  From $(epochsNum) epochs of length $(epochsLen)")
        println("  Creating $(sweepNum) sweeps of length $(sweepLen)")
        p = Progress(sweepNum, 1, "  Sweeps...    ", 50)
    end

    sweep = 1
    while sweep <= sweepNum

        sweepStart = (sweep-1)*(epochsPerSweep)+1
        sweepStop  = sweepStart + epochsPerSweep-1

        sweeps[:,sweep,:] = reshape(epochs[:,sweepStart:sweepStop,:],
                                                (sweepLen, 1, chansNum))

        if verbose; next!(p); end
        sweep += 1
    end

    return sweeps
end


#######################################
#
# F test
#
#######################################

function ftest(sweeps::Array, freq_of_interest::Number, fs::Number;
               verbose::Bool=false, side_freq::Number=2, used_filter::ZPKFilter=[])

    #TODO: Don't treat harmonic frequencies as noise

    average_sweep = squeeze(mean(sweeps,2),2)
    sweepLen      = size(average_sweep)[1]

    # Determine frequencies of interest
    frequencies = linspace(0, 1, int(sweepLen / 2 + 1))*fs/2
    idx      = _find_frequency_idx(frequencies, freq_of_interest)
    idx_Low  = _find_frequency_idx(frequencies, freq_of_interest - side_freq)
    idx_High = _find_frequency_idx(frequencies, freq_of_interest + side_freq)

    # Calculate amplitude at each frequency
    fftSweep    = 2 / sweepLen * fft(average_sweep)
    spectrum    = fftSweep[1:sweepLen / 2 + 1]

    # Compensate for filter response
    try
        h, f = response(used_filter, frequencies, fs)

        filter_compensation = Array(Float64, size(f))
        for freq=1:length(f)
            filter_compensation[freq] = abs(h[freq])*abs(h[freq])
        end

        spectrum = spectrum ./ filter_compensation
    catch
        if verbose
            println("Not incorporating filter response")
        end
    end

    signal_power = abs( spectrum[idx] )^2

    noise_bins_Low  = spectrum[idx_Low : idx-1]
    noise_bins_High = spectrum[idx+1 : idx_High]
    noise_bins = abs([noise_bins_Low[:], noise_bins_High[:]])
    noise_power = sum(noise_bins .^2) / length(noise_bins)

    snr = signal_power / noise_power
    snrDb = 10 * log10(snr)

    if verbose
        println("Frequencies = [$(freq_of_interest), ",
                               "$(freq_of_interest - side_freq), ",
                               "$(freq_of_interest + side_freq)]")
        println("Indicies    = [$(idx), ",
                               "$(idx_Low), ",
                               "$(idx_High)]")
        println("Bins below = $(idx - idx_Low) and above = $(idx_High - idx)")
        #Approx correct compared to matlab. Slight differences
        println(" ")
        println("Signal  = $(signal_power)")
        println("Noise   = $(noise_power)")
        println("SNR     = $(snr)")
        println("SNR dB  = $(snrDb)")
    end

    return snrDb, signal_power, noise_power
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

