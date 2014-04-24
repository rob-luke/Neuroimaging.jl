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
                                      channel_names::Dict)

    time = linspace(0, size(signals)[1]/fs, size(signals)[1])

    variances = var(signals,2)
    mean_variance = mean(variances)

    signals_plot = signals/mean_variance .+ [1:64]

    time_plot = FramedPlot(title = titletext,
                           xlabel = "Time (s)",
                           ylabel = "Channel")


    return time_plot
end
