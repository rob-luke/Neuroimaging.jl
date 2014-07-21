

#######################################
#
# Extract epochs
#
#######################################

function extract_epochs(dats::Array, evtTab::Dict; verbose::Bool=false)

    epochIndex = DataFrame(Code = evtTab["code"], Index = evtTab["idx"]);
    epochIndex[:Code] = epochIndex[:Code] - 252
    epochIndex = epochIndex[epochIndex[:Code].>0,:]
    epochIndex = epochIndex

    numEpochs = size(epochIndex)[1] - 1
    lenEpochs = minimum(diff(epochIndex[:Index]))
    numChans  = size(dats)[end]
    epochs = zeros(Float64, (int(lenEpochs), int(numEpochs), int(numChans)))

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

function epoch_rejection(epochs::Array;
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


