using DataFrames
using DSP


function proc_hp(signals::Array; cutOff::Number=2, order::Int=3, fs::Int=8192)

    signals = convert(Array{Float64}, signals)

    Wn = cutOff/(fs/2)
    f = digitalfilter(Highpass(Wn), Butterworth(order))

    chan = 1
    while chan <= size(signals)[1]
        signals[chan,:] = filt(f, vec(signals[chan,:]))
        signals[chan,:] = fliplr(signals[chan,:])
        signals[chan,:] = filt(f, vec(signals[chan,:]))
        signals[chan,:] = fliplr(signals[chan,:])
        chan += 1
    end

    return(signals)
end


function proc_rereference(signals::Array, refChan::Int)

    chan = 1
    while chan <= size(signals)[1]
        signals[chan,:] = signals[chan,:] - signals[refChan,:]
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

    if verbose
        println("Epoch length is $(lenEpochs)")
        println("Number of epochs is $(numEpochs)")
        println("Number of channels is $(numChans)")
    end

    epochs = zeros(Float64, (lenEpochs, numEpochs, numChans))

    chan = 1
    while chan <= numChans
        epoch = 1
        while epoch <= numEpochs

            startLoc = epochIndex[:Index][epoch]
            endLoc   = startLoc + lenEpochs - 1

            epochs[:,epoch, chan] = vec(dats[chan, startLoc:endLoc])

            epoch += 1
        end
        chan += 1
    end

    return epochs
end


function proc_sweeps(epochs::Array; epochsPerSweep::Int=4, verbose::Bool=false)

    epochsLen = size(epochs)[1]
    epochsNum = size(epochs)[2]
    chansNum  = size(epochs)[3]

    sweepLen = epochsLen * epochsPerSweep
    sweepNum = floor(epochsNum / epochsPerSweep)

    sweeps = zeros(Float64, (sweepLen, int(sweepNum), chansNum))

    if verbose
        println("From $(epochsNum) epochs of length $(epochsLen)")
        println("Creating $(sweepNum) sweeps of length $(sweepLen)")
    end

    sweep = 1
    while sweep <= sweepNum

        sweepStart = (sweep-1)*(epochsPerSweep)+1
        sweepStop  = sweepStart + epochsPerSweep-1

        sweeps[:,sweep,:] = reshape(epochs[:,sweepStart:sweepStop,:],
                                                (sweepLen, 1, chansNum))

        sweep += 1
    end

    return sweeps
end

