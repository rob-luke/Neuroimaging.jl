#######################################
#
# Filtering
#
#######################################

"""
    filter_highpass(a::EEG; cutOff::Real=2, fs::Real=samplingrate(a), order::Int=3, tolerance::Real=0.01, kwargs...)

Applly a high pass filter.

A zero phase high pass filter is applied to the data using `filtfilt`.
A check is performed to ensure the filter does not affect the modulation rate.
The filter coefficents are stored in the processing field.

# Examples
```julia
a = read_SSR(fname)
b = filter_highpass(a)
c = filter_highpass(a, cutOff = 1)
```

"""
function filter_highpass(
    a::EEG;
    cutOff::Union{typeof(1.0u"Hz"),typeof(1u"Hz")} = 2u"Hz",
    order::Int = 3,
    phase::AbstractString = "zero-double",
    kwargs...,
)
    Wn = (cutOff |> u"Hz" |> ustrip) / (samplingrate(Float64, a) / 2)
    f = digitalfilter(Highpass(Wn), Butterworth(order))
    a = filter(a, f, phase)
end


"""
    filter_lowpass(a::EEG; cutOff::Real=150, fs::Real=samplingrate(a), order::Int=3, tolerance::Real=0.01, kwargs...)

Applly a low pass filter.

A zero phase high pass filter is applied to the data using `filtfilt`.
A check is performed to ensure the filter does not affect the modulation rate.
The filter coefficents are stored in the processing field.

# Examples
```julia
a = read_SSR(fname)
b = filter_lowpass(a)
c = filter_lowpass(a, cutOff = 1)
```

"""
function filter_lowpass(
    a::EEG;
    cutOff::Union{typeof(1.0u"Hz"),typeof(1u"Hz")} = 150u"Hz",
    order::Int = 3,
    phase::AbstractString = "zero-double",
    kwargs...,
)
    Wn = (cutOff |> u"Hz" |> ustrip) / (samplingrate(Float64, a) / 2)
    f = digitalfilter(Lowpass(Wn), Butterworth(order))
    a = filter(a, f, phase)
end



"""
    filter_bandpass(a::EEG, lower, upper; n::Int=24, rp::Number = 0.0001, tolerance::Real=0.01, kwargs...)

Applly a band pass filter.
A check is performed to ensure the filter does not affect the modulation rate.
The filter coefficents are stored in the processing field.

# Examples
```julia
a = read_SSR(fname)
a = filter_bandpass(a)
```
"""
function filter_bandpass(
    a::EEG,
    lower::Union{typeof(1.0u"Hz"),typeof(1u"Hz")},
    upper::Union{typeof(1.0u"Hz"),typeof(1u"Hz")};
    n::Int = 24,
    rp::Number = 0.0001,
    phase::AbstractString = "zero-double",
    kwargs...,
)

    Wn_lower = (lower |> u"Hz" |> ustrip) / (samplingrate(Float64, a) / 2)
    Wn_upper = (upper |> u"Hz" |> ustrip) / (samplingrate(Float64, a) / 2)

    f = digitalfilter(Bandpass(Wn_lower, Wn_upper), Chebyshev1(n, rp))
    a = filter(a, f, phase)
end
