using DSP               # For filter types and conversion
using Winston           # For plotting filter response
using Polynomial        # For the polyval function



# Digital filter frequency response for frequency in radians per sample
function response(tff::TFFilter, w::Number)

    zml = exp(-im * w)
    h = polyval(tff.b, zml) / polyval(tff.a, zml)

    return h, w

end

function response(zpk_filter::ZPKFilter, w::Number)

    tff = convert(TFFilter, zpk_filter)
    h, w = response(tff, w)

    return h, w
end

# Digital filter frequency response for frequencies in radians per sample
function response(zpk_filter::ZPKFilter, w::Array)

    h = Array(Complex, size(f))
    for i = 1:length(w)
        h[i], w[i] = response(zpk_filter, w[i])
    end

    return h, w
end

# Digital filter frequency response for frequency in Hz
function response(zpk_filter::ZPKFilter, f::Number, fs::Integer)

    w = f * ((2*pi)/fs)
    h, w = response(zpk_filter, w)

    f = w * (fs/(2*pi))

    return h, f
end

# Digital filter frequency response for frequencies in Hz
function response(zpk_filter::ZPKFilter, f::Array, fs::Integer)

    h = Array(Complex, size(f))
    f_return = Array(Float64, size(f))

    for i = 1:length(f)
        h[i], f_return[i] = response(zpk_filter, f[i], fs)
    end

    return h, f_return
end


# Plot filter response
function plot_filter_response(zpk_filter::ZPKFilter, fs::Integer;
              lower::Number=1, upper::Number=30, sample_points::Int=1024)

    frequencies = linspace(lower, upper, 1024)
    h, f = response(zpk_filter, frequencies, fs)
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
