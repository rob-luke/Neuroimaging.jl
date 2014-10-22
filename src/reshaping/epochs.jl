
#######################################
#
# Extract epochs
#
#######################################

@doc md"""
Extract epoch data from array of channels.

### Input

* Array of raw data. Samples x Channels
* Dictionary of trigger information
* Vector of valid trigger numbers
* remove_first: Remove the first n triggers (0).
* valid_triggers: Trigger numbers that are considered valid ([1,2])

### Example

```julia
epochs = extract_epochs(data, triggers, [1,2], 0, 0)
```
""" ->
function extract_epochs(data::Array, triggers::Dict, valid_triggers::AbstractVector, remove_first::Int, remove_last::Int)

    validate_triggers(triggers)

    triggers = DataFrame(Code = triggers["Code"], Index = triggers["Index"])
    # TODO Use convert function
    #=triggers = convert(DataFrame, triggers)=#

    # Change offset so numbers are manageable
    triggers[:Code] = triggers[:Code] - 252

    # Determine indices of triggers which are valid
    valid_triggers = any(triggers[:Code] .== valid_triggers', 2)
    valid_triggers = find(valid_triggers .== true)

    # Remove unwanted triggers
    triggers = triggers[valid_triggers, :]                # That aren't valid
    triggers = triggers[remove_first+1:end-remove_last,:] # Often the first trigger is rubbish

    lenEpochs = minimum(diff(triggers[:Index]))
    numChans  = size(data)[end]

    # Check we aren't looking past the end of the data
    start_indices = triggers[:Index]
    end_indices   = start_indices + lenEpochs - 1
    while end_indices[end] > size(data, 1)
        pop!(start_indices)
        pop!(end_indices)
        warn("Removed end epoch as its not complete")
    end

    # Create variable for epochs
    numEpochs = length(start_indices)
    epochs = zeros(Float64, (int(lenEpochs), int(numEpochs), int(numChans)))

    # User feedback
    debug("Creating epochs: $lenEpochs x $numEpochs x $numChans")

    for si = 1:length(start_indices)
        epochs[:, si, :] = data[start_indices[si]: end_indices[si], :]
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
