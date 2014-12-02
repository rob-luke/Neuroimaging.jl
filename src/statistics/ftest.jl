using Distributions
using Gadfly

@doc md"""
Calculates the F test as is commonly implemented in SSR research.  
TODO: Add references to MASTER and Luts et al

### Parameters

* Sweep measurements. Samples x Sweeps x Channels
* Frequency(ies) of interest (Hz)
* Sampling rate (Hz)
* The amount of data to use on each side of frequency of interest to estimate noise (Hz)
* Filter used on the sweep data. If provided then is compensated for
* The number of bins to ignore on each side of the frequency of interest

### Returns

* Signal to noise ratio in dB
* Signal phase at frequency of interest
* Signal power at frequency of interest
* Noise power estimated of side frequencies
* F statistic

""" ->
function ftest(sweeps::Union(Array{Float64, 3}, Array{Float32, 3}), freq_of_interest::Real,
                fs::Real, side_freq::Real, used_filter::Union(Filter, Nothing), spill_bins::Int)

    spectrum    = EEG._ftest_spectrum(sweeps)
    frequencies = linspace(0, 1, int(size(spectrum, 1)))*float(fs)/2

    ftest(spectrum, frequencies, freq_of_interest, side_freq, spill_bins)
end


function ftest{T <: FloatingPoint}(spectrum::Array{Complex{T},2}, frequencies::AbstractArray,
            freq_of_interest::Real, side_freq::Real, spill_bins::Int)

    info("Calculating F statistic on $(size(spectrum)[end]) channels at $freq_of_interest Hz +-$(side_freq) Hz")

    idx      = _find_closest_number_idx(frequencies, freq_of_interest)
    idx_Low  = _find_closest_number_idx(frequencies, freq_of_interest - side_freq)
    idx_High = _find_closest_number_idx(frequencies, freq_of_interest + side_freq)

    # Determine signal phase
    signal_phase = angle(spectrum[idx, :])                             # Biased response phase

    # Determine signal power
    signal_power = abs(spectrum[idx, :]).^2                            # Biased response power

    # Determine noise power
    noise_idxs      = [idx_Low-spill_bins/2 : idx-spill_bins, idx+spill_bins : idx_High+spill_bins/2]
    noise_bins      = spectrum[noise_idxs,:]
    noise_bins      = abs(noise_bins)
    noise_power     = sum(noise_bins .^2, 1) ./ size(noise_bins,1)     # Recording noise power

    # Calculate SNR
    snr = (signal_power ./ noise_power)                                # Biased recording SNR
    snrDb = 10 * log10(snr)

    # Calculate statistic
    continuous_distribution = FDist(2, 2*size(noise_bins,1))
    statistic = ccdf(continuous_distribution, snr)

    # Debugging information
    debug("Frequencies = [$(freq_of_interest - side_freq), $(freq_of_interest), $(freq_of_interest + side_freq)]")
    debug("Indicies    = [$(minimum(noise_idxs)), $(idx), $(maximum(noise_idxs))]")
    debug("Noise bins  = $(size(noise_bins,1))")
    debug("Signal      = $(signal_power)")
    debug("Noise       = $(noise_power)")
    debug("SNR         = $(snr)")
    debug("SNR dB      = $(snrDb)")
    debug("Stat        = $(statistic)")

    return snrDb, signal_phase, signal_power, noise_power, statistic
end


# Calculates the spectrum for ftest and plotting
function _ftest_spectrum(sweep::Union(Array{Float64,1}, Array{Float64,2}); ref::Int=0)
    # First dimension is samples, second dimension if existing is channels

    sweepLen      = size(sweep)[1]

    # Calculate amplitude sweepe at each frequency along first dimension
    fftSweep    = 2 / sweepLen * fft(sweep, 1)
    spectrum    = fftSweep[1:sweepLen / 2 + 1, :]

    if ref > 0
        refspec = spectrum[:,ref]
        for i = 1:size(spectrum)[2]
            spectrum[:,i] = spectrum[:,i] - refspec
        end
    end

    return spectrum
end

function _ftest_spectrum(sweeps::Array{Float64,3};ref=0); _ftest_spectrum(squeeze(mean(sweeps,2),2),ref=ref); end
#=function _ftest_spectrum(s::Array{Float32}; ref=0); _ftest_spectrum(convert(Array{FloatingPoint}, s), ref=ref); end=#
#=function _ftest_spectrum(s::Array{Float64}; ref=0); _ftest_spectrum(convert(Array{FloatingPoint}, s), ref=ref); end=#


function plot_ftest{T <: FloatingPoint}(spectrum::Array{Complex{T},2}, frequencies::AbstractArray,
            freq_of_interest::Real, side_freq::Real, spill_bins::Int;
            min_plot_freq::Real=2, max_plot_freq::Real=2.2*freq_of_interest, plot_channel::Int=1, fig_name::String="ftest.pdf")


    idx      = _find_closest_number_idx(frequencies, freq_of_interest)
    idx_Low  = _find_closest_number_idx(frequencies, freq_of_interest - side_freq)
    idx_High = _find_closest_number_idx(frequencies, freq_of_interest + side_freq)

    # Determine signal power
    signal_power = abs(spectrum[idx, :]).^2

    # Determine noise power
    noise_idxs      = [idx_Low-spill_bins/2 : idx-spill_bins, idx+spill_bins : idx_High+spill_bins/2]
    noise_bins      = spectrum[noise_idxs,:]
    noise_bins      = abs(noise_bins)
    noise_power     = sum(noise_bins .^2, 1) ./ size(noise_bins,1)

    # Calculate SNR
    snr = (signal_power ./ noise_power)
    snrDb = 10 * log10(snr)

    idx_low_plot  = _find_closest_number_idx(frequencies, min_plot_freq)
    idx_high_plot = _find_closest_number_idx(frequencies, max_plot_freq)

    raw_plot = layer(x=frequencies[idx_low_plot:idx_high_plot], y=abs(spectrum[idx_low_plot:idx_high_plot, plot_channel]).^2, Geom.line, Theme(default_color=color("black")))
    noi_plot = layer(x=frequencies[noise_idxs], y=noise_bins.^2, Geom.line, Theme(default_color=color("red")))
    sig_plot = layer(x=frequencies[idx-1:idx+1], y=abs(spectrum[idx-1:idx+1, :]).^2, Geom.line, Theme(default_color=color("green")))
    noi_pnt  = layer(x=[min_plot_freq], y=[noise_power], Geom.point, Theme(default_color=color("red")))
    sig_pnt  = layer(x=[min_plot_freq], y=[signal_power], Geom.point, Theme(default_color=color("green")))
    #=sig_plot1 = layer(x=[freq_of_interest], y=[signal_power], Geom.point, Theme(default_color=color("green")))=#

    p = plot(noi_plot, sig_plot, raw_plot, noi_pnt, sig_pnt,
        Scale.x_continuous(minvalue=min_plot_freq, maxvalue=max_plot_freq),
        Scale.y_log10(),
        Guide.ylabel("Power (uV^2)"), Guide.xlabel("Frequency (Hz)"),
        Guide.title("SNR = $(round(snrDb[1], 3)) (dB)")
        )
    draw(PDF(fig_name, 26cm, 17cm), p)


end

