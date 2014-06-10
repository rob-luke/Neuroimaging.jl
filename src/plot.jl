# Plot information
#
# plot_spectrum
# plot_timeseries
# plot_timeseries_multichannel
# oplot
# oplot_dipoles
# plot_dat
#
# _place_plots
# _extract_plots
#


using Winston
using DSP: periodogram


#######################################
#
# Plot spectrum of signal
#
#######################################

function plot_spectrum(signal::Vector,
                        fs::Real;
                        titletext::String="",
                        Fmin::Int=0,
                        Fmax::Int=90,
                        targetFreq::Float64=0,
                        dBPlot::Bool=true,
                        noise_level::Number=0,
                        signal_level::Number=0)

    spectrum_plot = FramedPlot(
                        title = titletext,
                        xlabel = "Frequency (Hz)",
                        xrange = (Fmin, Fmax))

    # Determine fft frequencies
    signal_length = length(signal)
    frequencies = linspace(0, 1, int(signal_length / 2 + 1))*fs/2

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
            l = Legend(.85, .9, {s,n})
        elseif signal_level != 0
            l = Legend(.85, .9, {s})
        elseif noise_level != 0
            l = Legend(.85, .9, {n})
        end
        add(spectrum_plot, l)
    end

    return spectrum_plot
end


#######################################
#
# Plot time series
#
#######################################

# Single channel passed in as vector
function plot_timeseries(signal::Vector, fs::Real; titletext::String="")

    time = linspace(0,length(signal)/fs,length(signal))

    time_plot = FramedPlot(
                            title = titletext,
                            xlabel = "Time (s)",
                            ylabel = "Amplitude (uV)"
                        )
    add(time_plot, Curve( time, signal ))

    return time_plot
end


# Multiple channels passed in as an array
function plot_timeseries(signals::Array,
                         fs::Real;
                         titletext::String="",
                         chanLabels::Array=[],
                         plot_points::Int=1024)

    total_time = size(signals)[1]/fs

    fs = fs/plot_points

    plot_points = floor(linspace(1, size(signals)[1], plot_points))
    signals = signals[plot_points, :]

    time = linspace(1, total_time, length(plot_points))

    variances = var(signals,1)
    mean_variance = mean(variances)

    time_plot = FramedPlot(title = titletext,
                           xlabel = "Time (s)",
                           ylabel = "Channels",
                           yrange = (0, size(signals)[end]+1))

    for chan in 1:size(signals)[end]
        # Variance is set to 1, each channel is offset but 1 from the previous
        add(time_plot, Curve( time, convert(Array{Float64}, vec(signals[:, chan] / mean_variance .+ chan))))
    end

    #=chanLabels = convert(Array{ASCIIString}, chanLabels[1:64])=#

    setattr(time_plot.y1, draw_ticks=false, ticklabels=[""])
    setattr(time_plot, xrange=(0, total_time))

    return time_plot
end


#######################################
#
# Plot over existing plot
#
#######################################

function oplot(existing_plot, elec::Electrodes;
                        verbose::Bool=false,
                        color::String="red",
                        symbolkind::String="filled circle",
                        ncols::Int=2)

    p = oplot(existing_plot, elec.xloc, elec.yloc, elec.zloc,
        verbose=verbose, color=color, symbolkind=symbolkind, ncols=ncols)

    return p
end

function oplot(existing_plot, x, y, z;
                        verbose::Bool=false,
                        color::String="red",
                        symbolkind::String="filled circle",
                        ncols::Int=2)

    p = _extract_plots(existing_plot)

    # Points for each dipole
    for l in 1:length(x)
        add(p[1], Points(x[l], z[l], color=color, size=1, symbolkind=symbolkind))
        add(p[2], Points(y[l], z[l], color=color, size=1, symbolkind=symbolkind))
        add(p[3], Points(x[l], y[l], color=color, size=1, symbolkind=symbolkind))
    end

    p = _place_plots(p, ncols)
end


#######################################
#
# Plot over existing plot (dipoles)
#
#######################################

function oplot_dipoles(existing_plot, dipoles;
                        verbose::Bool=false,
                        color::String="red",
                        symbolkind::String="filled circle",
                        ncols::Int=2)

    # Generate table
    nrows = int(ceil(3/ncols))
    t = Table(nrows, ncols)

    # Extract existing plots
    back  = existing_plot[1,1]
    side  = existing_plot[1,2]
    top   = existing_plot[2,1]

    # Points for each dipole
    for p in 1:length(dipoles.xloc)

        add(back, Points(dipoles.xloc[p], dipoles.zloc[p], color=color, size=1, symbolkind=symbolkind))
        add(side, Points(dipoles.yloc[p], dipoles.zloc[p], color=color, size=1, symbolkind=symbolkind))
        add(top,  Points(dipoles.xloc[p], dipoles.yloc[p], color=color, size=1, symbolkind=symbolkind))

    end

    t = Table(2,2)
    t[1,1] = back
    t[1,2] = side
    t[2,1] = top

    return t
end


#######################################
#
# Plot dat file
#
#######################################

function plot_dat(x, y, z, dat_data;
                verbose::Bool=true,
                threshold_ratio::Number=1/1000,
                ncols::Int=2)

    max_value = maximum(dat_data)
    threshold = max_value * threshold_ratio

    size_multiplier = 2 / max_value

    back = FramedPlot(title = "Back",
                           xlabel = "Left - Right",
                           ylabel = "Inferior - Superior")

    side = FramedPlot(title = "Side",
                           xlabel = "Posterior - Anterior",
                           ylabel = "Inferior - Superior")

    top = FramedPlot(title = "Top",
                           xlabel = "Left - Right",
                           ylabel = "Posterior - Anterior")


    s = squeeze(maximum(dat_data,2),2)
    for xidx = 1:length(x)
        for zidx = 1:length(z)
            if s[xidx,zidx] > threshold
                add(back, Points(x[xidx], z[zidx], symbolkind="cross", size=s[xidx, zidx]*size_multiplier))
            end
        end
    end
    #=back = imagesc(s)=#
    #=colormap("jet", 200)=#

    s = squeeze(maximum(dat_data,1),1)
    for yidx = 1:length(y)
        for zidx = 1:length(z)
            if s[yidx,zidx] > threshold
                add(side, Points(y[yidx], z[zidx], symbolkind="cross", size=s[yidx, zidx]*size_multiplier))
            end
        end
    end

    s = squeeze(maximum(dat_data,3),3)
    for xidx = 1:length(x)
        for yidx = 1:length(y)
            if s[xidx,yidx] > threshold
                add(top, Points(x[xidx], y[yidx], symbolkind="cross", size=s[xidx, yidx]*size_multiplier))
            end
        end
    end

    t = _place_plots([back, side, top], ncols)

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
    nrows = int(ceil(length(plots)/ncols))
    t = Table(nrows, ncols)

    # Fill table with plots
    for idx = 1:length(plots)

        row = int(ceil(idx/ ncols))
        col = int(idx - (row-1)*ncols)

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
