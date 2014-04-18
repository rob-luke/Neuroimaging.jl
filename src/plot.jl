using Winston
using DSP: periodogram


function plotEEGSpectrum( signal::Vector )
    spectrum = periodogram( signal )
    spectrum = 10*log10( spectrum.^2 )
    spectrum = fftshift( spectrum )

    frequencies = linspace( -1, 1, length(spectrum) )

    spectrum_plot = FramedPlot(
                            title = "Spectrum",
                            xlabel = "f",
                            ylabel = "dB"
                        )
    add(spectrum_plot, Curve( frequencies, spectrum ))

    return spectrum_plot
end
