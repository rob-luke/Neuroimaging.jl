

#######################################
#
# Extract epochs
#
#######################################

function extract_epochs(dats::Array, evtTab::Dict)

    epochIndex = DataFrame(Code = evtTab["code"], Index = evtTab["idx"]);
    epochIndex[:Code] = epochIndex[:Code] - 252
    if findfirst(epochIndex[:Code], -4) > 0
        debug("Epochs for CI file")
        epochIndex = epochIndex[epochIndex[:Code].==-4,:]
    else
        debug("Epochs for NH file")
        epochIndex = epochIndex[epochIndex[:Code].>0,:]
    end
    epochIndex = epochIndex[2:end,:] # Often the first trigger is rubbish

    numEpochs = size(epochIndex)[1] - 1
    lenEpochs = minimum(diff(epochIndex[:Index]))
    numChans  = size(dats)[end]
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
# Reject epochs
#
#######################################

function epoch_rejection(epochs::Array; rejectionMethod::String="peak2peak", cutOff::Number=0.9)

    epochsLen = size(epochs)[1]
    epochsNum = size(epochs)[2]
    chansNum  = size(epochs)[3]

    info("Rejected $(int(round((1-cutOff)*100)))% of epochs")

    if rejectionMethod == "peak2peak"

        peak2peak = Float64[]

        epoch = 1
        while epoch <= epochsNum

            push!(peak2peak, maximum(epochs[:,epoch,:]) - minimum(epochs[:,epoch,:]))

            epoch += 1
        end

        cutOff = sort(peak2peak)[floor(length(peak2peak)*cutOff)]
        epochs = epochs[:, peak2peak.<cutOff, :]

    end

    return epochs
end


#######################################
#
# Create sweeps
#
#######################################

function create_sweeps(epochs::Array; epochsPerSweep::Int=4)

    epochsLen = size(epochs)[1]
    epochsNum = size(epochs)[2]
    chansNum  = size(epochs)[3]

    sweepLen = epochsLen * epochsPerSweep
    sweepNum = int(floor(epochsNum / epochsPerSweep))
    sweeps = zeros(Float64, (sweepLen, sweepNum, chansNum))

    sweep = 1
    while sweep <= sweepNum

        sweepStart = (sweep-1)*(epochsPerSweep)+1
        sweepStop  = sweepStart + epochsPerSweep-1

        sweeps[:,sweep,:] = reshape(epochs[:,sweepStart:sweepStop,:], (sweepLen, 1, chansNum))

        sweep += 1
    end

    info("Generated $sweepNum sweeps of length $sweepLen for $chansNum channels")

    return sweeps
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
