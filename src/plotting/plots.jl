
#######################################
#
# Plot spectrum of signal
#
#######################################

function plot_spectrum(signal::Vector,
                        fs::Real;
                        titletext::AbstractString="",
                        Fmin::Int=0,
                        Fmax::Int=90,
                        targetFreq::Float64=0.0,
                        dBPlot::Bool=true,
                        noise_level::Number=0,
                        signal_level::Number=0)

    # Determine fft frequencies
    signal_length = length(signal)
    frequencies = linspace(0, 1, Int(signal_length / 2 + 1))*fs/2

    # Calculate fft and convert to power
    fftSweep = 2 / signal_length * fft(signal)
    spectrum = abs(fftSweep[1:signal_length / 2 + 1])  # Amplitude
    spectrum = spectrum.^2

    valid_idx = (frequencies .<= Fmax) & (frequencies .>= Fmin)
    spectrum = spectrum[valid_idx]
    frequencies = frequencies[valid_idx]

    # Want a log plot?
    if dBPlot
        spectrum = 10*log10( spectrum )
        ylabel="Response Power (dB)"
    else
        ylabel="Response Power (uV^2)"
    end

    # Plot signal
    Plots.plot(frequencies, spectrum, lab = "Spectrum", color = :black)
    xlims!(Fmin, Fmax)
    xlabel!("Frequency (Hz)")
    ylabel!(ylabel)
    p = title!(titletext)

    # Plot the noise level if requested
    if noise_level != 0
        if dBPlot
            noise_level = 10*log10(noise_level)
        end
        p = plot!([Fmin, targetFreq+2], [noise_level, noise_level], lab = "Noise", color = :red)
    end

    # Plot the signal level if requested
    if signal_level != 0
        if dBPlot
            signal_level = 10*log10(signal_level)
        end
        plot!([Fmin, targetFreq], [signal_level, signal_level], lab = "Signal", color = :green)

        targetFreqIdx = findfirst(abs(frequencies.-targetFreq) , minimum(abs(frequencies.-targetFreq)))
        targetFreq    = frequencies[targetFreqIdx]
        targetResults = spectrum[targetFreqIdx]
        #TODO remove label for circle rather than make it empty
        p = plot!([targetFreq], [targetResults], marker = (:circle, 5, 0.1, :green), markerstrokecolor = :green, lab = "")
    end
    return p
end


function plot_spectrum(eeg::SSR, chan::Int; targetFreq::Number=0)

    channel_name = eeg.header["chanLabels"][chan]

    # Check through the processing to see if we have done a statistical test at target frequency
    signal = nothing
    result_idx = find_keys_containing(eeg.processing, "statistics")

    for r = 1:length(result_idx)
        result = get(eeg.processing, collect(keys(eeg.processing))[result_idx[r]], 0)
        if result[:AnalysisFrequency][1] == targetFreq

            result_snr = result[:SNRdB][chan]
            signal = result[:SignalAmplitude][chan]^2
            noise  = result[:NoiseAmplitude][chan]^2
            title  = "Channel $(channel_name). SNR = $(signif(result_snr, 4)) dB"
        end
    end

    if signal == nothing
        title  = "Channel $(channel_name)"
        noise  = 0
        signal = 0
    end

    title = replace(title, "_", " ")

    p = plot_spectrum(convert(Array{Float64}, vec(mean(eeg.processing["sweeps"], 2)[:,chan])),
                        eeg.header["sampRate"][1];
                        titletext=title, targetFreq = targetFreq,
                        noise_level = noise, signal_level = signal)

    return p
end

function plot_spectrum(eeg::SSR, chan::AbstractString; targetFreq::Number=0)

    return plot_spectrum(eeg, findfirst(eeg.header["chanLabels"], chan), targetFreq=targetFreq)
end
