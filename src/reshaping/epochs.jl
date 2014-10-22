
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

    # Determine which triggers are valid
    valid_triggers = any(triggers[:Code] .== valid_triggers', 2)
    valid_triggers = find(valid_triggers .== true)

    # Remove unwanted triggers
    triggers = triggers[valid_triggers, :]                # That aren't valid
    triggers = triggers[remove_first+1:end-remove_last,:] # Often the first trigger is rubbish

    # User feedback
    numEpochs = size(triggers)[1] - 1
    lenEpochs = minimum(diff(triggers[:Index]))
    numChans  = size(data)[end]
    debug("Creating epochs: $lenEpochs x $numEpochs x $numChans")

    epochs = zeros(Float64, (int(lenEpochs), int(numEpochs), int(numChans)))

    chan = 1
    while chan <= numChans
        epoch = 1
        while epoch <= numEpochs

            startLoc = triggers[:Index][epoch]
            endLoc   = startLoc + lenEpochs - 1

            epochs[:,epoch, chan] = vec(data[startLoc:endLoc, chan])

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
