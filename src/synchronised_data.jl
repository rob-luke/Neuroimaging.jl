
#######################################
#
# Clean trigger channel
#
#######################################

function clean_triggers(t::Dict; valid_indices::Array{Int}=[1, 2],
                        min_epoch_length::Int=0, max_epoch_length::Number=Inf,
                        remove_first::Int=0,     max_epochs::Number=Inf, kwargs...)

    info("Cleaning triggers")

    validate_triggers(t)

    # Make in to data frame for easy management
    epochIndex = DataFrame(Code = t["Code"], Index = t["Index"]);
    epochIndex[:Code] = epochIndex[:Code] - 252

    # Check for not valid indices and throw a warning
    if sum([in(i, [0, valid_indices]) for i = epochIndex[:Code]]) != length(epochIndex[:Code])
        non_valid = !convert(Array{Bool}, [in(i, [0, valid_indices]) for i = epochIndex[:Code]])
        non_valid = sort(unique(epochIndex[:Code][non_valid]))
        warn("File contains non valid triggers: $non_valid")
    end
    # Just take valid indices
    valid = convert(Array{Bool}, vec([in(i, valid_indices) for i = epochIndex[:Code]]))
    epochIndex = epochIndex[ valid , : ]

    # Trim values if requested
    if remove_first > 0
        epochIndex = epochIndex[remove_first+1:end,:]
        info("Trimming first $remove_first triggers")
    end
    if max_epochs < Inf
        epochIndex = epochIndex[1:minimum([max_epochs, length(epochIndex[:Index])]),:]
        info("Trimming to $max_epochs triggers")
    end

    # Throw out epochs that are the wrong length
    epochIndex[:Length] = [0, diff(epochIndex[:Index])]
    if min_epoch_length > 0
        epochIndex[:valid_length] = epochIndex[:Length] .> min_epoch_length
        num_non_valid = sum(!epochIndex[:valid_length])
        if num_non_valid > 1    # Don't count the first trigger
            warn("Removed $num_non_valid triggers < length $min_epoch_length")
            epochIndex = epochIndex[epochIndex[:valid_length], :]
        end
    end
    epochIndex[:Length] = [0, diff(epochIndex[:Index])]
    if max_epoch_length < Inf
        epochIndex[:valid_length] = epochIndex[:Length] .< max_epoch_length
        num_non_valid = sum(!epochIndex[:valid_length])
        if num_non_valid > 0
            warn("Removed $num_non_valid triggers > length $max_epoch_length")
            epochIndex = epochIndex[epochIndex[:valid_length], :]
        end
    end

    # Sanity check
    if std(epochIndex[:Length][2:end]) > 1
        warn("Your epoch lengths vary too much")
        warn(string("Length: median=$(median(epochIndex[:Length][2:end])) sd=$(std(epochIndex[:Length][2:end])) ",
              "min=$(minimum(epochIndex[:Length][2:end]))"))
        debug(epochIndex)
    end

    triggers = ["Index" => vec(int(epochIndex[:Index])'), "Code" => vec(epochIndex[:Code] .+ 252)]

    validate_triggers(triggers)

    return triggers
end


#######################################
#
# Validate trigger channel
#
#######################################

function validate_triggers(t::Dict; kwargs...)

    if t.count > 2
        err("Trigger channel has extra columns")
    end

    if !haskey(t, "Index")
        critical("Trigger channel does not contain index information")
    end

    if !haskey(t, "Code")
        critical("Trigger channel does not contain code information")
    end

end


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

    debug("Epochs = $lenEpochs x $numEpochs x $numChans")

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
