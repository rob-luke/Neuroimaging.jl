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
#######################################


function filter(
    s::NeuroimagingMeasurement,
    fcoef::FilterCoefficients,
    phase::AbstractString,
)
    if phase == "zero-double"

        s = filtfilt(s, fcoef)

    elseif phase == "zero"

        # TODO: behinger to do his magic

        # # append filterdelay as zeros
        # tau = filterdelay(fobj)
        # if ndims(s) >1 # todo: this feels hacky
        # 	# we want to add zeros at the end to get a longer signal for the filter, so that we can then correct the filter delay
        # 	s_dim2 = size(s)[2]
        # else
        # 	s_dim2 = 1
        # end
        # s = vcat(s,zeros(tau*2, s_dim2))


        # # filter
        # s = filt(fobj, s)

        # # fix grpdelay
        # s = s[tau+1:end-tau,:]

    else
        throw(
            ArgumentError(
                "Unknown filter phase argument $(phase). Must be one of zero-double or zero or ...",
            ),
        )
    end
    return s
end

function filt(s::NeuroimagingMeasurement, fcoef::FilterCoefficients)
    s2 = deepcopy(s)
    s2.data = DSP.filt(fcoef, data(s2))
    return s2
end

function filtfilt(s::NeuroimagingMeasurement, fcoef::FilterCoefficients)
    s2 = deepcopy(s)
    s2.data = DSP.filtfilt(fcoef, data(s2))
    return s2
end
