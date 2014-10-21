using Distributions


#######################################
#
# F test
#
#######################################

function ftest(sweeps::Array, freq_of_interest::Number, fs::Number;
               side_freq::Number=0.5, used_filter=nothing, spill_bins::Int=2, kwargs...)

    # Calculates the F test as is commonly implemented in SSR research
    #
    # ---------------------------------------------------------------------------
    #
    # Parameters    | ~
    # ------------- | ----------------------------------------------------------
    # `sweeps`      | Array of measurements. Samples x Sweeps x Channels
    # `freq`        | Frequency of interest (Hz)
    # `fs`          | Sampling rate (Hz)
    # `side_freq`   | The amount of data to use on each side of frequency of interest to estimate noise (Hz)
    # `used_filter` | Filter used on the sweep data. If provided then is compensated for
    # `spill_bins`  | The number of bins to ignore on each side of the frequency of interest
    #
    # ---------------------------------------------------------------------------
    #
    # Returns        | ~
    # -------------- | ----------------------------------------------------------
    # `snrDb`        | Signal to noise ratio in dB
    # `signal_phase` | Signal phase at frequency of interest
    # `signal_power` | Signal power at frequency of interest
    # `noise_power`  | Noise power estimated of side frequencies
    # `statistic`    | F statistic
    #
    # ---------------------------------------------------------------------------

    #TODO Don't treat harmonic frequencies as noise
    #TODO Better function description with references

    info("Calculating F statistic on $(size(sweeps)[end]) channels at $freq_of_interest Hz +-$(side_freq) Hz")

    # Determine frequencies of interest
    frequencies = linspace(0, 1, int(size(sweeps,1) / 2 + 1))*fs/2
    idx         = _find_closest_number_idx(frequencies, freq_of_interest)
    idx_Low     = _find_closest_number_idx(frequencies, freq_of_interest - side_freq)
    idx_High    = _find_closest_number_idx(frequencies, freq_of_interest + side_freq)

    # Calculate amplitude at each frequency
    spectrum    = _ftest_spectrum(sweeps)

    # Compensate for filter response
    if !(used_filter == nothing)
        filter_response     = freqz(used_filter, frequencies, fs)
        filter_compensation = [abs(f)^2 for f = filter_response]
        spectrum            = spectrum ./ filter_compensation
        debug("Accounted for filter response in F test spectrum estimation")
    end

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


