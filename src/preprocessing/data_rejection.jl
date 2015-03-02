@doc doc"""
Reject epochs based on the maximum peak to peak voltage within an epoch across all channels

### Input

* epochs: Array containing the epoch data in the format samples x epochs x channels
* retain_percentage: The percentage of epochs to retain
* rejection_method: Method to be used for epoch rejection (peak2peak)

### Output

* An array with a reduced amount of entries in the epochs dimension
""" ->
function epoch_rejection{T <: Number}(epochs::Array{T, 3}, retain_percentage::FloatingPoint;
                         rejection_method::Function=peak2peak)

    if (0 > retain_percentage) || (1 < retain_percentage)
        warn("Non valid percentage value for retaining epochs $(retain_percentage)")
    end

    info("Rejected $(int(round((1 - retain_percentage) * 100)))% of epochs based on $(string(rejection_method))")

    # Epoch value should be a value or score per epoch where a lower value is better
    # The lowest `retain_percentage` amount of epoch values will be kept
    epoch_values = rejection_method(epochs)

    cut_off_value = sort(epoch_values)[floor(length(epoch_values) * retain_percentage)]
    epochs = epochs[:, epoch_values .< cut_off_value, :]
end

# Find the peak to peak value for each epoch to be returned to epoch_rejection()
function peak2peak(epochs)

    epochsNum = size(epochs)[2]

    values = Array(FloatingPoint, epochsNum)
    for epoch in 1:epochsNum
        values[epoch] = abs(maximum(epochs[:, epoch, :]) - minimum(epochs[:, epoch, :]))
    end

    return values
end



#######################################
#
# Reject channels base on variance
#
#######################################

function channel_rejection(signals::AbstractArray; threshold_abs::Number=1000, threshold_var::Number=2, kwargs...)
    #
    # Rejects channels based on their variance
    # Values above an absolute threshold are removed
    # Of the remaining channels anything above several standard deviations is removed
    #
    # Input:     Array           samples x channels
    # Output:    Array{Bool}     Boolean array signifying if channel should be rejected

    debug("Rejecting channels for signal of $(size(signals,2)) chanels and $(size(signals,1)) samples")

    variances           = var(signals,1)
    valid_nonzero       = variances .!= 0    # The reference channel will have a variance of 0 so ignore it

    # Reject channels above the threshold
    valid_threshold_abs = variances .< threshold_abs

    # Reject channels outside median + n * std
    variances_median    = median(variances[valid_nonzero])
    variances_std       = std(variances[valid_nonzero])
    valid_threshold_var = variances  .<  (variances_median + threshold_var * variances_std)
    debug("Dynamic rejection threshold: $(variances_median + threshold_var * variances_std)")

    # Merge all methods
    valid_channels = valid_nonzero & valid_threshold_abs & valid_threshold_var
end
