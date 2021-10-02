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
* `plot()`


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


#######################################
#
# Plotting
#
# Use recipes for plotting.
# Here a base recipe is defined.
# Specific types can overide this.
#
#######################################


"""
    plot(n::NeuroimagingMeasurement)
    plot(n::NeuroimagingMeasurement, c::AbstractString)
    plot(n::NeuroimagingMeasurement, c::AbstractVector{AbstractString})

Plot the time series of the neuroimaing measurement.
If specified, only a selection of channels will be plotted.

# Examples
```julia
measurement = # load your neuroimaging data
plot(measurement)
plot(measurement, "TP7")
plot(measurement, ["TP7", "Cz"])
```
"""
@recipe function plot(s::NeuroimagingMeasurement)

    time_s = times(Float64, s)

    if size(data(s), 2) == 1

        labs = pop!(plotattributes, :label, channelnames(s)[1])

        RecipesBase.@series begin
            xguide := "Time (s)"
            yguide := "Amplitude (uV)"
            label := labs

            time_s, data(s)
        end

    else

        signals = data(deepcopy(s))
        variances = var(signals, dims = 1)
        mean_variance = Statistics.mean(variances)
        for c = 1:size(signals, 2)
            signals[:, c] = signals[:, c] .- Statistics.mean(signals[:, c])
            signals[:, c] = signals[:, c] ./ (mean_variance ./ 4) .+ (c - 1)
        end

        RecipesBase.@series begin
            seriestype := :path
            xguide := "Time (s)"
            yguide := "Amplitude (uV)"
            label := false
            yformatter := y -> ""
            yticks := (0:length(channelnames(s))-1, channelnames(s))

            time_s, signals
        end
    end
end

@recipe function plot(s::NeuroimagingMeasurement, c::S) where {S<:AbstractString}
    keep_channel!(deepcopy(s), [c])
end

@recipe function plot(
    s::NeuroimagingMeasurement,
    c::AbstractVector{S},
) where {S<:AbstractString}
    keep_channel!(deepcopy(s), c)
end

#######################################
#
# Internal functions
#
#######################################


"""
Internal function to find indices for channel names
"""
function _channel_indices(
    s::NeuroimagingMeasurement,
    channels::AbstractVector{S};
    warn_on_missing = true,
) where {S<:AbstractString}
    c_idx = Int[something(findfirst(isequal(c1), channelnames(s)), 0) for c1 in channels]
    if warn_on_missing
        if any(c_idx .== 0)
            throw(KeyError("Requested channel does not exist in $(channelnames(s))"))
        end
    end
    return c_idx
end
