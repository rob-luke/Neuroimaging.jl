#######################################
#
# Plot spectrum of signal
#
#######################################
"""
    plot_spectrum(signal::Vector, fs::Real; kwargs...)

Plot the spectrum of a signal.
"""
function plot_spectrum(
    signal::Vector,
    fs::Real;
    titletext::S = "",
    Fmin::Number = 0,
    Fmax::Number = 90,
    targetFreq::F = 0.0,
    dBPlot::Bool = true,
    noise_level::Number = 0,
    signal_level::Number = 0,
) where {S<:AbstractString,F<:AbstractFloat}

    # Determine fft frequencies
    signal_length = length(signal)
    frequencies = range(0, stop = 1, length = Int(signal_length / 2 + 1)) * fs / 2

    # Calculate fft and convert to power
    fftSweep = 2 / signal_length * fft(signal)
    spectrum = abs.(fftSweep[1:div(signal_length, 2)+1])  # Amplitude
    spectrum = spectrum .^ 2

    valid_idx = (frequencies .<= Fmax) .& (frequencies .>= Fmin)
    spectrum = spectrum[valid_idx]
    frequencies = frequencies[valid_idx]

    # Want a log plot?
    if dBPlot
        spectrum = 10 * log10.(spectrum)
        ylabel = "Response Power (dB)"
    else
        ylabel = "Response Power (uV^2)"
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
            noise_level = 10 * log10.(noise_level)
        end
        p = Plots.plot!(
            [Fmin, targetFreq + 2],
            [noise_level, noise_level],
            lab = "Noise",
            color = :red,
        )
    end

    # Plot the signal level if requested
    if signal_level != 0
        if dBPlot
            signal_level = 10 * log10.(signal_level)
        end
        Plots.plot!(
            [Fmin, targetFreq],
            [signal_level, signal_level],
            lab = "Signal",
            color = :green,
        )

        targetFreqIdx = something(
            findfirst(
                isequal(minimum(abs.(frequencies .- targetFreq))),
                abs.(frequencies .- targetFreq),
            ),
            0,
        )
        targetFreq = frequencies[targetFreqIdx]
        targetResults = spectrum[targetFreqIdx]
        #TODO remove label for circle rather than make it empty
        p = Plots.plot!(
            [targetFreq],
            [targetResults],
            marker = (:circle, 5, 0.1, :green),
            markerstrokecolor = :green,
            lab = "",
        )
    end
    return p
end


#######################################
#
# Filter response
#
#######################################

# Plot filter response
function plot_filter_response(
    zpk_filter::FilterCoefficients,
    fs::Integer;
    lower::Number = 1,
    upper::Number = 30,
    sample_points::Int = 1024,
)

    frequencies = range(lower, stop = upper, length = 1024)
    h = freqresp(zpk_filter, frequencies * ((2pi) / fs))
    magnitude_dB = 20 * log10.(convert(Array{Float64}, abs.(h)))
    phase_response = (360 / (2 * pi)) * unwrap(convert(Array{Float64}, angle.(h)))

    p1 = Plots.plot(frequencies, magnitude_dB, lab = "")
    p2 = Plots.plot(frequencies, phase_response, lab = "")

    p = Plots.plot(
        p1,
        p2,
        ylabel = ["Magnitude (dB)" "Phase (degrees)"],
        xlabel = "Frequency (Hz)",
        layout = @layout([a; b]),
    )
end
