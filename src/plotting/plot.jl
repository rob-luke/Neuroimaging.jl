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

import Winston.oplot

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
                        color::String="red",
                        symbolkind::String="filled circle",
                        ncols::Int=2)

    p = oplot(existing_plot, elec.xloc, elec.yloc, elec.zloc, color=color, symbolkind=symbolkind, ncols=ncols)

    return p
end

function oplot(existing_plot, x, y, z;
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

function oplot_dipoles(existing_plot, x, y, z;
                        color::String="red",
                        symbolkind::String="filled circle",
                        ncols::Int=2,
                        size::Number=1)

    # Generate table
    nrows = int(ceil(3/ncols))
    t = Table(nrows, ncols)

    # Extract existing plots
    back  = existing_plot[1,1]
    side  = existing_plot[1,2]
    top   = existing_plot[2,1]

    # Points for each dipole
    for p in 1:length(x)

        add(back, Points(x[p], z[p], color=color, size=size, symbolkind=symbolkind))
        add(side, Points(y[p], z[p], color=color, size=size, symbolkind=symbolkind))
        add(top,  Points(x[p], y[p], color=color, size=size, symbolkind=symbolkind))

    end

    t = Table(2,2)
    t[1,1] = back
    t[1,2] = side
    t[2,1] = top

    return t
end


function oplot(existing_plot::Table, dip::Union(Dipole, Coordinate);
                        color::String="red",
                        symbolkind::String="filled circle",
                        ncols::Int=2, size::Number=dip.size)

    oplot_dipoles(existing_plot, dip.x, dip.y, dip.z, color=color, symbolkind=symbolkind, ncols=ncols, size=size)
end


#######################################
#
# Plot dat file
#
#######################################

function plot_dat(x, y, z, dat_data;
                threshold_ratio::Number=1/1000,
                ncols::Int=2,
                max_size::Number=2)

    max_value = maximum(dat_data)
    threshold = max_value * threshold_ratio

    size_multiplier = max_size / max_value

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

function plot_dat(dat_data;
                threshold_ratio::Number=1/1000,
                ncols::Int=2)

    plot_dat(1:size(dat_data,1), 1:size(dat_data,2), 1:size(dat_data,3), dat_data,  threshold_ratio=threshold_ratio, ncols=ncols)

end

function plot_dat(dat_data::Array{FloatingPoint, 3};
                threshold_ratio::Number=1/1000,
                ncols::Int=2)


    x = 1:size(dat_data)[1]
    y = 1:size(dat_data)[2]
    z = 1:size(dat_data)[3]

    plot_dat(x, y, z, dat_data, threshold_ratio=threshold_ratio, ncols=ncols)
end



#######################################
#
# Type SSR
#
#######################################


# Plot whole all data
function plot_timeseries(eeg::SSR; titletext::String="")

    p = plot_timeseries(eeg.data, eeg.header["sampRate"][1], titletext=titletext)

    return p
end

# Plot a single channel
function plot_timeseries(eeg::SSR, chanName::String; titletext::String="")

    idx = findfirst(eeg.header["chanLabels"], chanName)

    p = plot_timeseries(vec(eeg.data[:, idx]), eeg.header["sampRate"][1], titletext=titletext)

    return p
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

function plot_spectrum(eeg::SSR, chan::String; targetFreq::Number=0)

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

function SSR_spectrogram(eeg::SSR, channel::String, lower::Number, upper::Number; seconds::Int=32)


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
