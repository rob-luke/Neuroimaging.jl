
using DSP


#######################################
#
# High pass filter
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
