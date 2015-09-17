#######################################
#
# Filtering
#
#######################################


function highpass_filter(a::SSR; cutOff::Number=2, order::Int=3, tolerance::Number=0.01, kwargs...)

    a.data, f = highpass_filter(a.data, cutOff, samplingrate(a), order)

    _filter_check(f, modulationrate(a), samplingrate(a), tolerance)

    _append_filter(a, f)
end


function lowpass_filter(a::SSR; cutOff::Number=150, order::Int=3, tolerance::Number=0.01, kwargs...)

    a.data, f = lowpass_filter(a.data, cutOff, samplingrate(a), order)

    _filter_check(f, modulationrate(a), samplingrate(a), tolerance)

    #= _append_filter(a, f) =#

    return a
end


function bandpass_filter(a::SSR;
                         lower::Number=modulationrate(a)-1,
                         upper::Number=modulationrate(a)+1,
                         n::Int=24, rp::Number=0.0001, tolerance::Number=0.01, kwargs...)

    # Type 1 Chebychev filter
    # The default options here are optimised for modulation frequencies 4, 10, 20, 40, 80
    # TODO filter check does not work here. Why not?
    # TODO automatic minimum filter order selection

    a.data, f = bandpass_filter(a.data, lower, upper, samplingrate(a), n, rp)

    _filter_check(f, modulationrate(a), samplingrate(a), tolerance)

    _append_filter(a, f)
end


function _filter_check(f::FilterCoefficients, mod_freq::Number, fs::Number, tolerance::Number)
    #
    # Ensure that the filter does not alter the modulation frequency greater than a set tolerance
    #

    mod_change = abs(freqz(f, mod_freq, fs))
    if mod_change > 1 + tolerance || mod_change < 1 - tolerance
        warn("Filtering has modified modulation frequency greater than set tolerance: $mod_change")
    end
    debug("Filter magnitude at modulation frequency: $(mod_change)")
end


function _append_filter(a::SSR, f::FilterCoefficients; name::String="filter")
    #
    # Put the filter information in the SSR processing structure
    #

    key_name = new_processing_key(a.processing, name)
    merge!(a.processing, [key_name => f])

    return a
end



#######################################
#
# Downsample
#
#######################################

function downsample(s::SSR, ratio::Rational)

    info("Downsampling SSR by ratio $ratio")

    dec_filter  = DSP.FIRFilter([1], ratio)

    new_data = zeros(typeof(s.data[1, 1]), int(size(s.data, 1)*ratio), size(s.data, 2))

    for c in 1:size(s.data, 2)

        new_data[:, c] = DSP.filt(dec_filter, vec(s.data[:, c]))
    end

    s.data = new_data

    s.triggers["Index"] = int(round(s.triggers["Index"] .* ratio))
    if s.triggers["Index"][1] == 0
        s.triggers["Index"][1] = 1
    end

    s.samplingrate = float(samplingrate(s) * ratio) * Hertz

    return s
end


#######################################
#
# Change reference channels
#
#######################################

function rereference(a::SSR, refChan::Union(String, Array{ASCIIString}); kwargs...)

    a.data = rereference(a.data, refChan, a.channel_names)

    a.reference_channel = [refChan]

    return a
end
