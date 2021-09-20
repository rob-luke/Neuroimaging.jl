#######################################
#
# Filtering
#
#######################################

"""
    filter_highpass(a::EEG; cutOff::Real=2, fs::Real=samplingrate(a), order::Int=0, kwargs...)

Apply a high pass filter.

If order is zero then its computed magically.

# Examples
```julia
a = read_EEG(fname)
b = filter_highpass(a)
c = filter_highpass(a, cutOff = 1)
```
"""
function filter_highpass(
    a::EEG;
    cutOff::Union{typeof(1.0u"Hz"),typeof(1u"Hz")} = 2u"Hz",
    order::Int = 0,
    phase::AbstractString = "zero",
    kwargs...,
)
    Wn = (cutOff |> u"Hz" |> ustrip) / (samplingrate(Float64, a) / 2)
    if order == 0
        order = default_fir_filterorder(Highpass(Wn), samplingrate(Float64, a)) + 1
    end
    f = digitalfilter(Highpass(Wn), FIRWindow(DSP.hamming(order)))
    a = filter(a, f, phase)
end


"""
    filter_lowpass(a::EEG; cutOff::Real=150, fs::Real=samplingrate(a), order::Int=0, kwargs...)

Apply a low pass filter.

If order is zero then its computed magically.

# Examples
```julia
a = read_EEG(fname)
b = filter_lowpass(a)
c = filter_lowpass(a, cutOff = 1)
```
"""
function filter_lowpass(
    a::EEG;
    cutOff::Union{typeof(1.0u"Hz"),typeof(1u"Hz")} = 150u"Hz",
    order::Int = 0,
    phase::AbstractString = "zero",
    kwargs...,
)
    Wn = (cutOff |> u"Hz" |> ustrip) / (samplingrate(Float64, a) / 2)
    if order == 0
        order = default_fir_filterorder(Lowpass(Wn), samplingrate(Float64, a)) + 1
    end
    f = digitalfilter(Lowpass(Wn), FIRWindow(DSP.hamming(order)))
    a = filter(a, f, phase)
end



"""
    filter_bandpass(a::EEG, lower, upper; n::Int=24, rp::Number = 0.0001, kwargs...)

Apply a band pass filter.

# Examples
```julia
a = read_EEG(fname)
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
