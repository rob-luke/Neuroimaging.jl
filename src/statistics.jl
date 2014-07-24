


#######################################
#
# F test
#
#######################################

function ftest(sweeps::Array, freq_of_interest::Number, fs::Number; side_freq::Number=2, used_filter=nothing)

    #TODO: Don't treat harmonic frequencies as noise

    # Determine frequencies of interest
    frequencies = linspace(0, 1, int(size(sweeps,1) / 2 + 1))*fs/2
    idx      = _find_frequency_idx(frequencies, freq_of_interest)
    idx_Low  = _find_frequency_idx(frequencies, freq_of_interest - side_freq)
    idx_High = _find_frequency_idx(frequencies, freq_of_interest + side_freq)

    # Calculate amplitude at each frequency
    spectrum    = _ftest_spectrum(sweeps)

    # Compensate for filter response
    if !(used_filter == nothing)
        h = freqz(used_filter, frequencies, fs)

        filter_compensation = Array(Float64, size(frequencies))
        for freq=1:length(frequencies)
            filter_compensation[freq] = abs(h[freq])*abs(h[freq])
        end

        spectrum = spectrum ./ filter_compensation
        debug("Accounted for filter response in F test spectrum estimation")
    else
        debug("Not incorporating filter response in F test")
    end

    # Determine signal power
    signal_power = abs( spectrum[idx, :] ).^2

    # Determine noise power
    # Ignore one bin either side
    noise_idxs      = [idx_Low-1:idx-2, idx+2:idx_High+1]

    noise_bins      = spectrum[noise_idxs,:]
    noise_bins      = abs(noise_bins)
    noise_power     = sum(noise_bins .^2, 1) ./ size(noise_bins,1)

    # Return SNR
    snr = (signal_power ./ noise_power)
    snrDb = 10 * log10(snr)

    # Calculate statistic
    continuous_distribution = FDist(2, 2*size(noise_bins,1))
    statistic = ccdf(continuous_distribution, snr)

    debug("Frequencies = [$(freq_of_interest - side_freq), ",
                           "$(freq_of_interest), ",
                           "$(freq_of_interest + side_freq)]")
    debug("Indicies    = [$(minimum(noise_idxs)), ",
                           "$(idx), ",
                           "$(maximum(noise_idxs))]")
    debug("Noise bins  = $(size(noise_bins,1))")
    debug("Signal  = $(signal_power)")
    debug("Noise   = $(noise_power)")
    debug("SNR     = $(snr)")
    debug("SNR dB  = $(snrDb)")
    debug("Stat    = $(statistic)")

    return snrDb, signal_power, noise_power, statistic
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


#######################################
#
# Global field power
#
#######################################

function gfp(x::Array)

    samples, sensors = size(x)

    info("Computing global field power for $sensors sensors and $samples samples")

    result = zeros(samples,1)

    for sample = 1:samples
        u = squeeze(x[sample,:],1) .- mean(x[sample,:])
        sumsqdif = 0
        for sensor = 1:sensors
            for sensor2 = 1:sensors
                sumsqdif += (u[sensor] - u[sensor2])^2
            end
        end
        result[sample] = sqrt(sumsqdif / (2*length(samples)))
    end

    return result
end



