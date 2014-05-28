using DSP               # For filter types and conversion
using Winston           # For plotting filter response
using Polynomial        # For the polyval function


# Digital filter frequency response for frequency in radians per sample
function response(zpk_filter::ZPKFilter, w::Number)

    # Port of https://github.com/scipy/scipy/blob/v0.13.0/scipy/signal/filter_design.py#L153

    tff = convert(TFFilter, zpk_filter)

    a = tff.a
    b = tff.b

    zml = exp(-im * w)

    h = polyval(b, zml) / polyval(a, zml)

    return h, w
end

# Digital filter frequency response for frequencies in radians per sample
function response(zpk_filter, w::Array)

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

    p = plot(f, magnitude_dB)

    xlabel("Frequency (Hz)")
    ylabel("Magnitude (dB)")
    title("Filter Response")

    #=display_range = maximum(magnitude_dB) - minimum(magnitude_dB)=#
    #=add(p, Curve(f, (display_range/2)/pi.*convert(Array{Float64},=#
                        #=angle(h)).-(display_range/2), color="red", kind="dotted"))=#

    return p
end
