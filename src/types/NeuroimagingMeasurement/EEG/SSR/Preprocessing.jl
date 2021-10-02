#######################################
#
# Filtering
#
#######################################

"""
    filter_highpass(a::SSR; cutOff::Real=2, fs::Real=samplingrate(a), order::Int=3, tolerance::Real=0.01, kwargs...)

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
    a::SSR;
    cutOff::Union{typeof(1.0u"Hz"),typeof(1u"Hz")} = 2u"Hz",
    order::Int = 3,
    tolerance::Real = 0.01,
    phase::AbstractString = "zero-double",
    kwargs...,
)
    Wn = (cutOff |> u"Hz" |> ustrip) / (samplingrate(Float64, a) / 2)
    f = digitalfilter(Highpass(Wn), Butterworth(order))
    _filter_check(f, modulationrate(a), samplingrate(Float64, a), tolerance)
    a = filter(a, f, phase)
    _append_filter(a, f)
end


"""
    filter_lowpass(a::SSR; cutOff::Real=150, fs::Real=samplingrate(a), order::Int=3, tolerance::Real=0.01, kwargs...)

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
    a::SSR;
    cutOff::Union{typeof(1.0u"Hz"),typeof(1u"Hz")} = 150u"Hz",
    order::Int = 3,
    tolerance::Real = 0.01,
    phase::AbstractString = "zero-double",
    kwargs...,
)
    Wn = (cutOff |> u"Hz" |> ustrip) / (samplingrate(Float64, a) / 2)
    f = digitalfilter(Lowpass(Wn), Butterworth(order))
    _filter_check(f, modulationrate(a), samplingrate(Float64, a), tolerance)
    a = filter(a, f, phase)
    _append_filter(a, f)
end



"""
    filter_bandpass(a::SSR; lower::Number=modulationrate(a) - 1, upper::Number=modulationrate(a) + 1, fs::Real=samplingrate(a), n::Int=24, rp::Number = 0.0001, tolerance::Real=0.01, kwargs...)

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
    a::SSR;
    lower::Union{typeof(1.0u"Hz"),typeof(1u"Hz")} = (modulationrate(a) - 1) * 1.0u"Hz",
    upper::Union{typeof(1.0u"Hz"),typeof(1u"Hz")} = (modulationrate(a) + 1) * 1.0u"Hz",
    n::Int = 24,
    rp::Number = 0.0001,
    tolerance::Number = 0.01,
    phase::AbstractString = "zero-double",
    kwargs...,
)

    Wn_lower = (lower |> u"Hz" |> ustrip) / (samplingrate(Float64, a) / 2)
    Wn_upper = (upper |> u"Hz" |> ustrip) / (samplingrate(Float64, a) / 2)

    f = digitalfilter(Bandpass(Wn_lower, Wn_upper), Chebyshev1(n, rp))
    _filter_check(f, modulationrate(a), samplingrate(Float64, a), tolerance)
    a = filter(a, f, phase)
    _append_filter(a, f)
end


function _filter_check(
    f::FilterCoefficients,
    mod_freq::Number,
    fs::Number,
    tolerance::Number,
)
    #
    # Ensure that the filter does not alter the modulation frequency greater than a set tolerance
    #

    mod_change = abs.(freqresp(f, mod_freq * ((2pi) / fs)))



    if mod_change > 1 + tolerance || mod_change < 1 - tolerance
        @warn(
            "Filtering has modified modulation frequency greater than set tolerance: $mod_change"
        )
    end
    @debug("Filter magnitude at modulation frequency: $(mod_change)")
end


function _append_filter(a::SSR, f::FilterCoefficients; name::AbstractString = "filter")
    #
    # Put the filter information in the SSR processing structure
    #

    key_name = new_processing_key(a.processing, name)
    merge!(a.processing, Dict(key_name => f))

    return a
end



#######################################
#
# Downsample
#
#######################################

"""
    downsample(s::SSR, ratio::Rational)

Downsample signal by specified ratio.

"""
function downsample(s::SSR, ratio::Rational)

    @info("Downsampling SSR by ratio $ratio")

    dec_filter = DSP.FIRFilter([1], ratio)

    new_data =
        zeros(typeof(s.data[1, 1]), round.(Int, size(s.data, 1) * ratio), size(s.data, 2))

    for c = 1:size(s.data, 2)

        new_data[:, c] = DSP.filt(dec_filter, vec(s.data[:, c]))
    end

    s.data = new_data

    s.triggers["Index"] = round.(Int, s.triggers["Index"] .* ratio)
    if s.triggers["Index"][1] == 0
        s.triggers["Index"][1] = 1
    end

    s.samplingrate = float(samplingrate(Float64, s) * ratio) * 1.0u"Hz"

    return s
end
