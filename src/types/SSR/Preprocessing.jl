#######################################
#
# Filtering
#
#######################################

function filter(
    obj::SSR,
    responsetype::FilterType;
    designmethod=Butterworth(6),
    kwargs...
)
return filter(obj,responsetype,designmethod;filtfilt=true,kwargs...)
end


"""
    highpass_filter(a::SSR; cutOff::Real=2, fs::Real=samplingrate(a), order::Int=3, tolerance::Real=0.01, kwargs...)

Applly a high pass filter.

A zero phase high pass filter is applied to the data using `filtfilt`.
A check is performed to ensure the filter does not affect the modulation rate.
The filter coefficents are stored in the processing field.

# Examples
```julia
a = read_SSR(fname)
b = highpass_filter(a)
c = highpass_filter(a, cutOff = 1)
```

"""
function highpass_filter(
    a::SSR;
    cutOff::Real = 2,
    fs::Real = samplingrate(a),
    order::Int = 3,
    tolerance::Real = 0.01,
    kwargs...,
)

    a.data, f = highpass_filter(a.data, cutOff, fs, order)

    _filter_check(f, modulationrate(a), fs, tolerance)

    _append_filter(a, f)
end

"""
    lowpass_filter(a::SSR; cutOff::Real=150, fs::Real=samplingrate(a), order::Int=3, tolerance::Real=0.01, kwargs...)

Applly a low pass filter.

A zero phase high pass filter is applied to the data using `filtfilt`.
A check is performed to ensure the filter does not affect the modulation rate.
The filter coefficents are stored in the processing field.

# Examples
```julia
a = read_SSR(fname)
b = lowpass_filter(a)
c = lowpass_filter(a, cutOff = 1)
```

"""
function lowpass_filter(
    a::SSR;
    cutOff::Real = 150,
    fs::Real = samplingrate(a),
    order::Int = 3,
    tolerance::Real = 0.01,
    kwargs...,
)

    a.data, f = lowpass_filter(a.data, cutOff, fs, order)

    _filter_check(f, modulationrate(a), fs, tolerance)

    #= _append_filter(a, f) =#

    return a
end


"""
    bandpass_filter(a::SSR; lower::Number=modulationrate(a) - 1, upper::Number=modulationrate(a) + 1, fs::Real=samplingrate(a), n::Int=24, rp::Number = 0.0001, tolerance::Real=0.01, kwargs...)

Applly a band pass filter.
A check is performed to ensure the filter does not affect the modulation rate.
The filter coefficents are stored in the processing field.

# Examples
```julia
a = read_SSR(fname)
a = bandpass_filter(a)
```
"""
function bandpass_filter(
    a::SSR;
    lower::Number = modulationrate(a) - 1,
    upper::Number = modulationrate(a) + 1,
    n::Int = 24,
    rp::Number = 0.0001,
    tolerance::Number = 0.01,
    kwargs...,
)

    # Type 1 Chebychev filter
    # The default options here are optimised for modulation frequencies 4, 10, 20, 40, 80
    # TODO filter check does not work here. Why not?
    # TODO automatic minimum filter order selection

    a.data, f = bandpass_filter(a.data, lower, upper, samplingrate(a), n, rp)

    _filter_check(f, modulationrate(a), samplingrate(a), tolerance)

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

    s.samplingrate = float(samplingrate(s) * ratio) * 1.0u"Hz"

    return s
end
