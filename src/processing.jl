using DataFrames
using DSP

function extractEpochs(dats::Array, evtTab::Dict, verbose::Bool=false)

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

            epoch = epoch + 1
        end
        chan = chan + 1
    end

    return epochs
end


function filterEEG(signals::Array)

    signals = convert(Array{Float64}, signals)

    cutOff = 2
    Wn = cutOff/(8192/2)
    #=println("Cut off of $(cutOff) = $Wn ")=#

    f = digitalfilter(Highpass(Wn), Butterworth(3))

    chan = 1
    while chan <= size(signals)[1]
        signals[chan,:] = filt(f, vec(signals[chan,:]))
        signals[chan,:] = fliplr(signals[chan,:])
        signals[chan,:] = filt(f, vec(signals[chan,:]))
        signals[chan,:] = fliplr(signals[chan,:])
        chan = chan + 1
    end

    return(signals)

end


function epochs2sweeps(epochs::Array, epochsPerSweep::Int=4, verbose::Bool=false)

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

        sweeps[:,sweep,:] = reshape(epochs[:,sweepStart:sweepStop,:], (sweepLen, 1, chansNum))

        sweep = sweep + 1
    end


    return sweeps

end


function rereference(signals::Array, refChan::Int=33)

    chan = 1
    while chan <= size(signals)[1]

        signals[chan,:] = signals[chan,:] - signals[refChan,:]

        chan = chan + 1
    end

    return signals

end

