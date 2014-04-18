using Winston
using DSP: periodogram


function plotChannelSpectrum( signal::Vector, fs::Real, titletext::String, Fmin::Int=0, Fmax::Int=90, targetFreq::Float64=40.0391)

    # Code adapted from https://github.com/JayKickliter/Radio.jl/blob/ad49640f77aa5a4237a34871bbde6b64265021dc/src/Support/Graphics.jl
    spectrum = periodogram( signal )
    spectrum = 10*log10( spectrum.^2 )
    spectrum = fftshift( spectrum )
    spectrum = spectrum[size(signal)[1]/2+1:end]

    frequencies = linspace(0,1,length(spectrum))*fs/2

    spectrum_plot = FramedPlot(
                            title = titletext,
                            xlabel = "Frequency (Hz)",
                            ylabel = "Response (dB)",
                            xrange = (Fmin, Fmax)
                        )
    add(spectrum_plot, Curve( frequencies, spectrum ))

    targetFreqIdx = findfirst(abs(frequencies.-targetFreq) , minimum(abs(frequencies.-targetFreq)))
    targetFreq    = frequencies[targetFreqIdx]
    targetResults = spectrum[targetFreqIdx]

    a = Points(targetFreq, targetResults, kind="circle", color="blue")
    add(spectrum_plot, a)

    return spectrum_plot

end


function plotChannelTime( signal::Vector, fs::Real, titletext::String)

    time = linspace(0,length(signal)/fs,length(signal))

    time_plot = FramedPlot(
                            title = titletext,
                            xlabel = "Time (s)",
                            ylabel = "Amplitude (uV)"
                        )
    add(time_plot, Curve( time, signal ))

    return time_plot

end
