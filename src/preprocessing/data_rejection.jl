
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
