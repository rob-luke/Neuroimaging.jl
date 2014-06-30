using DSP               # For filter types and conversion


# Plot filter response
function plot_filter_response(zpk_filter::ZPKFilter, fs::Integer;
              lower::Number=1, upper::Number=30, sample_points::Int=1024)

    frequencies = linspace(lower, upper, 1024)

    h = freqz(zpk_filter, frequencies, fs)

    magnitude_dB = 20*log10(convert(Array{Float64}, abs(h)))
    phase_response = (360/(2*pi))*unwrap(convert(Array{Float64}, angle(h)))

    mag_plot = FramedPlot(
         title="Filter Response",
         ylabel="Magnitude (dB)")
    add(mag_plot, Curve(frequencies, magnitude_dB, color="black"))

    phase_plot = FramedPlot(
         xlabel="Frequency (Hz)",
         ylabel="Phase (degrees)")
    add(phase_plot, Curve(frequencies, phase_response, color="black"))

    t = Table(2,1)
    t[1,1] = mag_plot
    t[2,1] = phase_plot

    return t
end
