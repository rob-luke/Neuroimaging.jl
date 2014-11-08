using DSP


#######################################
#
# High pass filter
#
#######################################

function highpass_filter(signals::Array; cutOff::Number=2,
                         order::Int=3, fs::Number=8192)

    signals = convert(Array{Float64}, signals)

    Wn = cutOff/(fs/2)
    f = digitalfilter(Highpass(Wn), Butterworth(order))

    info("Highpass filtering $(size(signals)[end]) channels.  Pass band > $(cutOff) Hz")
    debug("Filter order = $order, fs = $fs, Wn = $Wn")

    signals = filtfilt(f, signals)

    return signals, f
end


#######################################
#
# Low pass filter
#
#######################################

function lowpass_filter(signals::Array; cutOff::Number=2,
                         order::Int=3, fs::Number=8192)

    signals = convert(Array{Float64}, signals)

    Wn = cutOff/(fs/2)
    f = digitalfilter(Lowpass(Wn), Butterworth(order))

    info("Lowpass filtering $(size(signals)[end]) channels.  Pass band < $(cutOff) Hz")
    debug("Filter order = $order, fs = $fs, Wn = $Wn")

    signals = filtfilt(f, signals)

    return signals, f
end


#######################################
#
# Band pass filter
#
#######################################

function bandpass_filter(signals::Array, lower::Number, upper::Number, fs::Number, n::Int, rp::Number)

    # Type 1 Chebychev filter
    # TODO filtfilt does not work. Why not?

    signals = convert(Array{Float64}, signals)

    f = digitalfilter(Bandpass(lower, upper, fs=fs), Chebyshev1(n, rp))

    info("Bandpass filtering $(size(signals)[end]) channels.     $lower < Hz < $upper")
    debug("Filter order = $n, fs = $fs")

    signals = filt(f, signals)
    signals = filt(f, flipud(signals))
    signals = flipud(signals)

    return signals, f
end


#######################################
#
# Filter compensation
#
#######################################

function compensate_for_filter(d::Dict, spectrum::AbstractArray, fs::Real)

    frequencies = linspace(0, 1, int(size(spectrum, 1))) * fs / 2

    key_name = "filter"
    key_numb = 1
    key      = string(key_name, key_numb)

    while haskey(d, key)

        used_filter         = d[key]
        filter_response     = freqz(used_filter, frequencies, fs)
        for f = 1:length(filter_response)
            spectrum[f, :, :] = spectrum[f, :, :] ./ abs(filter_response[f])^2
        end

        debug("Accounted for $key response in hotelling test spectrum estimation")

        key_numb += 1
        key = string(key_name, key_numb)
    end

    return spectrum
end
