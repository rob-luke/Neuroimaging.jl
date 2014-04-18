using Winston
using DSP: periodogram


function plotChannelSpectrum( signal::Vector, fs::Real, titletext::String)
    # Code taken from https://github.com/JayKickliter/Radio.jl/blob/ad49640f77aa5a4237a34871bbde6b64265021dc/src/Support/Graphics.jl
    spectrum = periodogram( signal )
    spectrum = 10*log10( spectrum.^2 )
    spectrum = fftshift( spectrum )
    spectrum = spectrum[length(spectrum)/2:end]

    frequencies = linspace( 0, 1, length(spectrum) )*fs/2

    spectrum_plot = FramedPlot(
                            title = titletext,
                            xlabel = "Frequency (Hz)",
                            ylabel = "Response (dB)"
                        )
    add(spectrum_plot, Curve( frequencies, spectrum ))

    return spectrum_plot
end



function plotChannelTime( signal::Vector, fs::Real, titletext::String)

    time = linspace( 1, length(signal)/fs, length(signal))

    time_plot = FramedPlot(
                            title = titletext,
                            xlabel = "Time (s)",
                            ylabel = "Amplitude (uV)"
                        )
    add(time_plot, Curve( time, signal ))

    return time_plot
end
