
using DSP


#######################################
#
# High pass filter
#
#######################################

function bandpass_filter(signals::Array, lower::Number, upper::Number, fs::Number;
                         n::Int=3, rp::Number=0.001, rs::Number=30)

    signals = convert(Array{Float64}, signals)

    f = digitalfilter(Bandpass(lower, upper, fs=fs), Elliptic(n, rp, rs))

    info("Bandpass filtering $(size(signals)[end]) channels.     $lower < Hz < $upper")
    debug("Filter order = $order, fs = $fs")

    signals = filtfilt(f, signals)

    return signals, f
end
