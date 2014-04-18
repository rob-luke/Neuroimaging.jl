using DataFrames

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

