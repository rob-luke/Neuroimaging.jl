"""
Abstract type for storing Neuroimaing data.

All other neuroimaging types inherit from this type.
All neuroimaing types support the following functions:

* `samplingrate()`
* `channelnames()`
* `remove_channel!()`
* `keep_channel!()`
* `trim_channel()`
* `highpass_filter()`
* `lowpass_filter()`
* `data()`

# Examples
```julia
data = # load your neuroimaging data
samplingrate(data)  # Returns the sampling rate
channelnames(data)  # Returns the channel names
```
"""
abstract type NeuroimagingMeasurement end


#######################################
#
# Filtering
#
# We provide maximum flexibility to users by providing filt and filtfilt
# to be performed on any NeuroimagingMeasurement.
# On top of this flexible default, methods are provided for each subtype
# of EEG measurements in their associated directories.
#
#######################################


function filt(
    s::NeuroimagingMeasurement,
    fcoef::Union{FilterCoefficients,AbstractVector{F}},
) where {F<:AbstractFloat}
    s2 = deepcopy(s)
    s2.data = DSP.filt(fcoef, data(s2))
    return s2
end

function filtfilt(
    s::NeuroimagingMeasurement,
    fcoef::Union{FilterCoefficients,AbstractVector{F}},
) where {F<:AbstractFloat}
    s2 = deepcopy(s)
    s2.data = DSP.filtfilt(fcoef, data(s2))
    return s2
end

function filter(
    s::NeuroimagingMeasurement,
    fcoef::Union{FilterCoefficients,AbstractVector{F}},
    phase::AbstractString,
) where {F<:AbstractFloat}
    if phase == "zero-double"

        s = filtfilt(s, fcoef)

    elseif phase == "zero"

        # # append filterdelay as zeros
        tau = filterdelay(fcoef)
        if ndims(s.data) > 1 # todo: this feels hacky
            # we want to add zeros at the end to get a longer signal for the filter, so that we can then correct the filter delay
            s_dim2 = size(s.data)[2]
        else
            s_dim2 = 1
        end
        s.data = vcat(s.data, zeros(tau * 2, s_dim2))


        # # filter
        s = filt(s, fcoef)

        # # fix grpdelay
        s.data = s.data[tau+1:end-tau, :]

    else
        throw(
            ArgumentError(
                "Unknown filter phase argument $(phase). Must be one of zero-double or zero or ...",
            ),
        )
    end
    return s
end
