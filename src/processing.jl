using DataFrames
using DSP
using ProgressMeter


function proc_hp(signals::Array; cutOff::Number=2,
                   order::Int=3, fs::Int=8192, verbose::Bool=false)

    signals = convert(Array{Float64}, signals)

    Wn = cutOff/(fs/2)
    f = digitalfilter(Highpass(Wn), Butterworth(order))

    if verbose
        println("Highpass filtering $(size(signals)[1]) channels")
        println("  Pass band > $(cutOff) Hz")
        p = Progress(size(signals)[1], 1, "  Filtering... ", 50)
    end

    chan = 1
    while chan <= size(signals)[1]
        signals[chan,:] = filt(f, vec(signals[chan,:]))
        signals[chan,:] = fliplr(signals[chan,:])
        signals[chan,:] = filt(f, vec(signals[chan,:]))
        signals[chan,:] = fliplr(signals[chan,:])
        if verbose; next!(p); end
        chan += 1
    end

    return(signals)
end


function proc_rereference(signals::Array, refChan::Int; verbose::Bool=false)

    if verbose
        println("Re referencing $(size(signals)[1]) channels")
        p = Progress(size(signals)[1], 1, "  Rerefing...  ", 50)
    end

    chan = 1
    while chan <= size(signals)[1]
        signals[chan,:] = signals[chan,:] - signals[refChan,:]
        if verbose; next!(p); end
        chan += 1
    end

    return signals
end


function proc_epochs(dats::Array, evtTab::Dict; verbose::Bool=false)

    epochIndex = DataFrame(Code = evtTab["code"], Index = evtTab["idx"]);
    epochIndex = epochIndex[epochIndex[:Code].==252,:]
    epochIndex = epochIndex[epochIndex[:Code].==252,:]
    epochIndex = epochIndex[2:end,:]

    numEpochs = size(epochIndex)[1] - 1
    lenEpochs = minimum(diff(epochIndex[:Index]))
    numChans  = size(dats)[1]
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

            epochs[:,epoch, chan] = vec(dats[chan, startLoc:endLoc])

            epoch += 1
        end
        if verbose; next!(p); end
        chan += 1
    end

    return epochs
end


function proc_sweeps(epochs::Array; epochsPerSweep::Int=4, verbose::Bool=false)

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


function _find_frequency_idx(freq_array::Array, freq_of_interest::Number;
                                verbose::Bool=false)

    diff_array = abs(freq_array - freq_of_interest)
    targetIdx  = findfirst(diff_array , minimum(diff_array))

    if verbose
        println("Frequency index is $(targetIdx) is $(freq_array[targetIdx]) Hz")
    end

    return targetIdx
end

