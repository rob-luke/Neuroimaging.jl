using Winston
using DSP: periodogram


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


function plot_timeseries_multichannel(signals::Array,
                                      fs::Real;
                                      titletext::String="",
                                      chanLabels::Array=[],
                                      plot_points::Int=1024)

    total_time = size(signals)[2]/fs

    fs = fs/plot_points

    plot_points = floor(linspace(1, size(signals)[2], plot_points))
    signals = signals[:, plot_points]

    time = linspace(1, total_time, length(plot_points))

    variances = var(signals,2)
    mean_variance = mean(variances)

    signals_plot = signals/mean_variance .+ [1:64]

    time_plot = FramedPlot(title = titletext,
                           xlabel = "Time (s)",
                           ylabel = "Channels",
                           yrange = (0, 65))

    for chan in 1:64
        add(time_plot, Curve( time, convert(Array{Float64}, vec(signals_plot[chan,:]))))
    end

    #=chanLabels = convert(Array{ASCIIString}, chanLabels[1:64])=#

    setattr(time_plot.y1, draw_ticks=false, ticklabels=[""])
    setattr(time_plot, xrange=(0, total_time))

    return time_plot
end


function oplot_dipoles(existing_plot, dipoles; verbose::Bool=false, color::String="red")

    # Extract existing plots
    back = existing_plot[1,1]
    side  = existing_plot[1,2]
    top = existing_plot[2,1]

    # Points for each dipole
    for p in 1:length(dipoles.xloc)

        add(back, Points(dipoles.xloc[p], dipoles.zloc[p], color=color, size=2, symbolkind="plus"))
        add(side, Points(dipoles.yloc[p], dipoles.zloc[p], color=color, size=2, symbolkind="plus"))
        add(top,  Points(dipoles.xloc[p], dipoles.yloc[p], color=color, size=2, symbolkind="plus"))

    end

    t = Table(2,2)
    t[1,1] = back
    t[1,2] = side
    t[2,1] = top

    return t

end


function plot_dat(x, y, z, dat_data;
                verbose::Bool=true,
                threshold_ratio::Number=1/1000)

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


    t = Table(2,2)
    t[1,1] = back
    t[1,2] = side
    t[2,1] = top

    return t

end
