
#######################################
#
# Extract epochs
#
#######################################

function extract_epochs(dats::Array, evtTab::Dict; remove_first::Int=0)

    epochIndex = DataFrame(Code = evtTab["Code"], Index = evtTab["Index"]);
    epochIndex[:Code] = epochIndex[:Code] - 252
    if findfirst(epochIndex[:Code], -4) > 0
        debug("Epochs for CI file")
        epochIndex = epochIndex[epochIndex[:Code].==-4,:]
        if remove_first == 0
            remove_first += 1
        end
    else
        debug("Epochs for NH file")
        epochIndex = epochIndex[epochIndex[:Code].>0,:]
    end
    epochIndex = epochIndex[remove_first+1:end,:] # Often the first trigger is rubbish


    numEpochs = size(epochIndex)[1] - 1
    lenEpochs = minimum(diff(epochIndex[:Index]))
    numChans  = size(dats)[end]

    debug("Creating epochs: $lenEpochs x $numEpochs x $numChans")

    epochs = zeros(Float64, (int(lenEpochs), int(numEpochs), int(numChans)))

    chan = 1
    while chan <= numChans
        epoch = 1
        while epoch <= numEpochs

            startLoc = epochIndex[:Index][epoch]
            endLoc   = startLoc + lenEpochs - 1

            epochs[:,epoch, chan] = vec(dats[startLoc:endLoc, chan])

            epoch += 1
        end
        chan += 1
    end

    info("Generated $numEpochs epochs of length $lenEpochs for $numChans channels")

    return epochs
end


#######################################
#
# Create average epochs
#
#######################################

function average_epochs(ep::Array)

    info("Averaging down epochs to 1 epoch of length $(size(ep,1)) from $(size(ep,2)) epochs on $(size(ep,3)) channels")

    squeeze(mean(ep, 2), 2)
end
