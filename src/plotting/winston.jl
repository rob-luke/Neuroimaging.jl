#######################################
#
# Plot dat file
#
#######################################

@doc md"""
Plot a 3d image file from three views (back, side and top).

#### Arguments

* x, y, z: Axis dimensions
* dat_data: Activity at each location

#### Optional Arguments

* ncols: number of colums used for output plot
* max_size: maximum size for any point
* min_size: minimum size for any point
* min_plot_lim: values smaller than this will not be plotted
* threshold: values smaller than this will be set to smallest plot size
* title: places custom text over second plot facet
* colorbar: should a color bar be plotted  (current implementation is a hack until colorbar support is added to winston)
* colorbar_title: units to be stated under colorbar
* plot_negative: should negative values be plotted

""" ->
function plot_dat{T <: AbstractFloat}(x::Array{T, 1}, y::Array{T, 1}, z::Array{T, 1}, dat_data::Array{Float64, 3};
                ncols::Int=3, max_size::Number=1, min_size=0.2,
                min_plot_lim::Number = unique(sort(abs(vec(dat_data))))[2], threshold::Number = -Inf,
                colorbar::Bool=false, colorbar_title::AbstractString="",
                title::AbstractString="", plot_negative::Bool=true, units::AbstractString="?", kwargs...)

    size_multiplier = max_size / maximum(dat_data)

    # Replace the description with a custom title if requested
    if title == ""
        middle_title = "Side"
    else
        middle_title = title
    end

    back = subplot_dat(x, z, 2, dat_data, plot_negative, size_multiplier, min_size, T, min_plot_lim, threshold,
                "Back", string("Left - Right (", units, ")"), string("Inferior - Superior (" , units, ")"); kwargs...)

    side = subplot_dat(y, z, 1, dat_data, plot_negative, size_multiplier, min_size, T, min_plot_lim, threshold,
                middle_title, string("Posterior - Anterior (", units, ")"), string("Inferior - Superior (", units, ")"); kwargs...)

    top =  subplot_dat(x, y, 3, dat_data, plot_negative, size_multiplier, min_size, T, min_plot_lim, threshold,
                "Top",  string("Left - Right (", units, ")"), string("Posterior - Anterior (", units, ")"); kwargs...)

    p = 0
    # Create a color bar
    if colorbar
        s = collapse_dat(dat_data, 3, plot_negative)
        dmin = minimum(s)
        dmax = maximum(s)
        p=FramedPlot(aspect_ratio=10.0, xlabel=colorbar_title)
        setattr(p.x, draw_ticks=false)
        setattr(p.y1, draw_ticks=false)
        setattr(p.x1, draw_ticklabels=false)
        setattr(p.y1, draw_ticklabels=false)
        setattr(p.y2, draw_ticklabels=true)
        xr=(1,2)
        yr=(dmin,dmax)
        y=linspace(dmin, dmax, 256)*1.0
        data=[y y]
        setattr(p, :xrange, xr)
        setattr(p, :yrange, yr)
        clims = (minimum(data),maximum(data))
        img = Winston.data2rgb(data, clims, Winston.colormap())
        add(p, Image(xr, yr, img))

        cb=FramedPlot(aspect_ratio=1.0)
        setattr(cb.x, draw_ticks=false)
        setattr(cb.y1, draw_ticks=false)
        setattr(cb.x1, draw_ticklabels=false)
        setattr(cb.y1, draw_ticklabels=false)
        setattr(cb.y2, draw_ticklabels=false)
        setattr(cb.y2, draw_axis=false)
        setattr(cb.y2, draw_axis=false)
        setattr(cb.x1, draw_axis=false)
        setattr(cb.x2, draw_axis=false)
        setattr(cb.x, draw_axis=false)
        setattr(cb.y, draw_axis=false)
        a = Points(0, 0, kind="dot")
        add(cb, a)
        add(cb, PlotInset((0.1, 0.1), (0.2, 0.9), p))

        p = EEG._place_plots([back, side, top, cb], ncols)
    else

        p = EEG._place_plots([back, side, top], ncols)
    end

    p
end

function subplot_dat(x_dim, y_dim, reduction_dim, dat_data, plot_negative, size_multiplier, min_size, T, min_plot_lim,
            threshold, title, xlab, ylab; kwargs...)

    s = collapse_dat(dat_data, reduction_dim, plot_negative)    # Data along dimensions to be plotted
    x_tmp = zeros(T, size(s, 1) * size(s, 2), 1)                # Preallocate x locations
    y_tmp = zeros(T, size(s, 1) * size(s, 2), 1)                # Preallocate y locations
    s_tmp = zeros(T, size(s, 1) * size(s, 2), 1)                # Preallocate scatter size
    c_tmp = zeros(T, size(s, 1) * size(s, 2), 1)                # Preallocate scatter color

    i = 1
    for xidx = 1:length(x_dim)
        for yidx = 1:length(y_dim)

            x_tmp[i] = x_dim[xidx]                              # Scatter require the data in vector format
            y_tmp[i] = y_dim[yidx]                              # So reshape x, y, scale and color to vectors

            if abs(s[xidx, yidx]) > min_plot_lim                # This ensures the outline of the brain is shown
                if abs(s[xidx,yidx]) > threshold                # User set value for highlighting region of interest

                    s_tmp[i] = abs(s[xidx, yidx]) * size_multiplier
                    c_tmp[i] = s[xidx, yidx]

                else
                    s_tmp[i] = min_size
                    c_tmp[i] = min_size
                end
            end
            i += 1
        end
    end
    s_tmp = abs(s_tmp)

    scatter(x_tmp, y_tmp, [0 < i < min_size ? min_size : i for i in s_tmp], c_tmp, "x",
        title = title, xlabel = xlab, ylabel = ylab; kwargs...)
end


function collapse_dat(dat_data, dim, plot_negative)

    s = squeeze(maxabs(dat_data, dim), dim)

    if plot_negative

        smin = squeeze(minimum(dat_data, dim), dim)

        negate_me = s .== (smin * -1)

        s[negate_me] = s[negate_me] * -1

    end

    return s
end


function plot_dat(dat_data; kwargs...)

    plot_dat(1:size(dat_data,1), 1:size(dat_data,2), 1:size(dat_data,3), dat_data; kwargs...)
end


function plot_dat{T <: Number}(dat_data::Array{T, 3}; kwargs...)

    x = 1:size(dat_data)[1]
    y = 1:size(dat_data)[2]
    z = 1:size(dat_data)[3]

    plot_dat(x, y, z, dat_data; kwargs...)
end


#######################################
#
# Plot over existing dat plot (dipoles)
#
#######################################

function oplot_dipoles(existing_plot, x, y, z;
                        color::AbstractString="red",
                        symbolkind::AbstractString="filled circle",
                        ncols::Int=2,
                        size::Number=1)

    ep = _extract_plots(existing_plot)

    for p in 1:length(x)

        add(ep[1], Points(x[p], z[p], color=color, size=size, symbolkind=symbolkind))
        add(ep[2], Points(y[p], z[p], color=color, size=size, symbolkind=symbolkind))
        add(ep[3], Points(x[p], y[p], color=color, size=size, symbolkind=symbolkind))
    end

    _place_plots(ep, ncols)
end


function oplot(existing_plot::Table, dip::Coordinate; kwargs...)

    oplot_dipoles(existing_plot, dip.x, dip.y, dip.z; kwargs...)
end




#######################################
#
# Plot over existing plot
#
#######################################

function oplot(existing_plot, elec::Electrodes;
                        color::AbstractString="red",
                        symbolkind::AbstractString="filled circle",
                        ncols::Int=2, kwargs...)

    p = oplot(existing_plot, elec.xloc, elec.yloc, elec.zloc, color=color, symbolkind=symbolkind, ncols=ncols; kwargs...)

    return p
end

function oplot(existing_plot, x, y, z;
                        color::AbstractString="red",
                        symbolkind::AbstractString="filled circle",
                        ncols::Int=2, kwargs...)

    p = _extract_plots(existing_plot)

    # Points for each dipole
    for l in 1:length(x)
        add(p[1], Points(x[l], z[l], color=color, size=1, symbolkind=symbolkind; kwargs...))
        add(p[2], Points(y[l], z[l], color=color, size=1, symbolkind=symbolkind; kwargs...))
        add(p[3], Points(x[l], y[l], color=color, size=1, symbolkind=symbolkind; kwargs...))
    end

    p = _place_plots(p, ncols)
end



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

    spectrum_plot = FramedPlot(
                        title = titletext,
                        xlabel = "Frequency (Hz)",
                        xrange = (Fmin, Fmax))

    # Determine fft frequencies
    signal_length = length(signal)
    frequencies = linspace(0, 1, Int(signal_length / 2 + 1))*fs/2

    # Calculate fft and convert to power
    fftSweep = 2 / signal_length * fft(signal)
    spectrum = abs(fftSweep[1:signal_length / 2 + 1])  # Amplitude
    spectrum = spectrum.^2

    # Want a log plot?
    if dBPlot
        spectrum = 10*log10( spectrum )
        setattr(spectrum_plot, ylabel="Response Power (dB)")
    else
        setattr(spectrum_plot, ylabel="Response Power (uV^2)")
    end

    # Plot signal
    p = Curve( frequencies, spectrum )
    #=setattr(p, label="Spectrum")=#
    add(spectrum_plot, p)

    # Plot the noise level if requested
    if noise_level != 0
        if dBPlot
            noise_level = 10*log10(noise_level)
        end
        #=n = Slope(0, (0,noise_level),=#
            #=kind="dotted",=#
            #=color="red")=#
        n = Curve([0, targetFreq+2], [noise_level,noise_level],
            kind="dotted",
            color="red")
        setattr(n, label="Noise")
        add(spectrum_plot, n)
    end

    # Plot the signal level if requested
    if signal_level != 0
        if dBPlot
            signal_level = 10*log10(signal_level)
        end
        #=s = Slope(0, (0,signal_level),=#
            #=kind="dotted",=#
            #=color="blue")=#
        s = Curve([0, targetFreq],
            [signal_level, signal_level],
            color="blue",
            kind="dotted")
        setattr(s, label="Signal")
        add(spectrum_plot, s)

        targetFreqIdx = findfirst(abs(frequencies.-targetFreq) , minimum(abs(frequencies.-targetFreq)))
        targetFreq    = frequencies[targetFreqIdx]
        targetResults = spectrum[targetFreqIdx]

        t = Points(targetFreq, targetResults, kind="circle", color="blue")
        add(spectrum_plot, t)

    end

    if signal_level != 0 || noise_level != 0
        if signal_level != 0 && noise_level != 0
            l = Legend(.85, .9, Any[s,n])
        elseif signal_level != 0
            l = Legend(.85, .9, Any[s])
        elseif noise_level != 0
            l = Legend(.85, .9, Any[n])
        end
        add(spectrum_plot, l)
    end

    return spectrum_plot
end


function plot_spectrum(eeg::SSR, chan::Int; targetFreq::Number=0)

    channel_name = eeg.header["chanLabels"][chan]

    # Check through the processing to see if we have done a statistical test at target frequency
    signal = nothing
    result_idx = find_keys_containing(eeg.processing, "ftest")

    for r = 1:length(result_idx)
        result = get(eeg.processing, collect(keys(eeg.processing))[result_idx[r]], 0)
        if result[:Frequency][1] == targetFreq

            result_snr = result[:SNRdB][chan]
            signal = result[:SignalPower][chan]
            noise  = result[:NoisePower][chan]
            title  = "Channel $(channel_name). SNR = $(result_snr) dB"
        end
    end

    if signal == nothing
        title  = "Channel $(channel_name)"
        noise  = 0
        signal = 0
    end

    p = plot_spectrum(convert(Array{Float64}, vec(mean(eeg.processing["sweeps"], 2)[:,chan])),
                        eeg.header["sampRate"][1];
                        titletext=title, targetFreq = targetFreq,
                        noise_level = noise, signal_level = signal)

    return p
end

function plot_spectrum(eeg::SSR, chan::AbstractString; targetFreq::Number=0)

    return plot_spectrum(eeg, findfirst(eeg.header["chanLabels"], chan), targetFreq=targetFreq)
end


function SSR_spectrogram(eeg::SSR, channel::Int, lower::Number, upper::Number; seconds::Int=32)

    fs = eeg.header["sampRate"][channel]

    spec = spectrogram(vec(eeg.data[:, channel]), seconds*fs)

    xrange = linspace(minimum(spec.time)./ fs, maximum(spec.time)./ fs, length(spec.time))
    yrange = linspace(minimum(spec.freq).* fs, maximum(spec.freq).* fs, length(spec.freq));

    y = [findfirst(yrange, upper):-1:findfirst(yrange, lower)]
    yrange = yrange[y]

    yrange_ends = (minimum(yrange), maximum(yrange))
    xrange_ends = (minimum(xrange), maximum(xrange))

    i = imagesc(xrange_ends, yrange_ends, 10*log10(spec.power[y, :]))
    xlabel("Time (s)")
    ylabel("Frequency (Hz)")
    title(string(eeg.header["chanLabels"][channel], " Spectrogram"))

    power = spec.power[y, :]

    # This is not correct!!!!
    # TODO: fix
    response_power = mean(power, 2)
    noise = std(power, 2)
    snr = 10*log10(response_power ./ noise)

    s = plot(snr, yrange)
    ylim(maximum(yrange), minimum(yrange))
    xlabel("SNR (dB)")
    title(string(eeg.header["chanLabels"][channel], " SNR"))

    t2 = Table(1, 2)
    t2[1,1] = i
    t2[1,2] = s

    return t2
end

function SSR_spectrogram(eeg::SSR, channel::AbstractString, lower::Number, upper::Number; seconds::Int=32)


    SSR_spectrogram(eeg, findfirst(eeg.header["chanLabels"], channel), lower, upper, seconds=seconds)
end


#######################################
#
# Filter response
#
#######################################

# Plot filter response
function plot_filter_response(zpk_filter::Filter, fs::Integer;
              lower::Number=1, upper::Number=30, sample_points::Int=1024)

    frequencies = linspace(lower, upper, 1024)
    h = freqz(zpk_filter, frequencies, fs)
    #=h = freqs(zpk_filter, frequencies, fs)=#
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



#######################################
#
# Helper functions
#
#######################################

function _place_plots(plots::Array, ncols::Int)
    #= Place plots in to table

    Parameters
    ----------
    plots : Array{FramedPlot,1}
        Plots to be placed in to a table

    ncols : integer
        Number of columns to make in the table

    Returns
    -------
    t : Table
        Winston table filled with framed plots

    Usage
    -----
    p = _extract_plots(t)
    t = _place_plots(p, 2)

    =#

    # Generate table
    nrows = round(Int, ceil(length(plots)/ncols))
    t = Table(nrows, ncols)

    # Fill table with plots
    for idx = 1:length(plots)

        row = round(Int, ceil(idx/ ncols))
        col = round(Int, idx - (row-1)*ncols)

        t[row, col] = plots[idx]

    end

    return t
end


function _extract_plots(t::Table)
    #= Extract framed plots from a table

    Parameters
    ----------
    t : Table
        Winston table that may contain empty blocks

    Returns
    -------
    plots : Array{FramedPlot,1}
        Array containing framed plots

    Usage
    -----
    t = _place_plots(p, 2)
    p = _extract_plots(t)

    =#

    plots = FramedPlot[]

    for r = 1:t.rows
        for c = 1:t.cols
            try                         # Required in case of partly filled table
                push!(plots, t[r,c])
            end
        end
    end

    return plots
end
