"""
    plot_spectrum(eeg::SSR, chan::Int; kwargs...)
    plot_spectrum(eeg::SSR, chan::AbstractString; kwargs...)

Plot the spectrum of a steady state response measurement.
"""
function plot_spectrum(eeg::SSR, chan::Int; targetFreq::Number = modulationrate(eeg))

    channel_name = channelnames(eeg)[1]

    # Check through the processing to see if we have done a statistical test at target frequency
    signal = nothing
    result_idx = find_keys_containing(eeg.processing, "statistics")

    for r = 1:length(result_idx)
        result = get(eeg.processing, collect(keys(eeg.processing))[result_idx[r]], 0)
        if result[!, :AnalysisFrequency][1] == targetFreq

            result_snr = result[!, :SNRdB][chan]
            signal = result[!, :SignalAmplitude][chan]^2
            noise = result[!, :NoiseAmplitude][chan]^2
            title = "Channel $(channel_name). SNR = $(round(result_snr, sigdigits=4)) dB"
        end
    end

    if signal == nothing
        title = "Channel $(channel_name)"
        noise = 0
        signal = 0
    end

    title = replace(title, "_" => " ")

    avg_sweep = dropdims(Statistics.mean(eeg.processing["sweeps"], dims = 2), dims = 2)
    avg_sweep = avg_sweep[:, chan]
    avg_sweep = convert(Array{Float64}, vec(avg_sweep))

    p = plot_spectrum(
        avg_sweep,
        eeg.header["sampRate"][1];
        titletext = title,
        targetFreq = targetFreq,
        noise_level = noise,
        signal_level = signal,
    )

    return p
end

function plot_spectrum(
    eeg::SSR,
    chan::AbstractString;
    targetFreq::Number = modulationrate(eeg),
)

    return plot_spectrum(
        eeg,
        something(findfirst(isequal(chan), channelnames(eeg)), 0),
        targetFreq = targetFreq,
    )
end
