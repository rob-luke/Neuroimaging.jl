


#######################################
#
# F test
#
#######################################

function ftest(sweeps::Array, freq_of_interest::Number, fs::Number;
               verbose::Bool=false, side_freq::Number=2, used_filter=nothing)

    #TODO: Don't treat harmonic frequencies as noise

    average_sweep = squeeze(mean(sweeps,2),2)
    sweepLen      = size(average_sweep)[1]

    # Determine frequencies of interest
    frequencies = linspace(0, 1, int(sweepLen / 2 + 1))*fs/2
    idx      = _find_frequency_idx(frequencies, freq_of_interest)
    idx_Low  = _find_frequency_idx(frequencies, freq_of_interest - side_freq)
    idx_High = _find_frequency_idx(frequencies, freq_of_interest + side_freq)

    # Calculate amplitude at each frequency
    fftSweep    = 2 / sweepLen * fft(average_sweep)
    spectrum    = fftSweep[1:sweepLen / 2 + 1]

    # Compensate for filter response
    if !(used_filter == nothing)
        h = freqz(used_filter, frequencies, fs)

        filter_compensation = Array(Float64, size(frequencies))
        for freq=1:length(frequencies)
            filter_compensation[freq] = abs(h[freq])*abs(h[freq])
        end

        spectrum = spectrum ./ filter_compensation
    else
        if verbose
            println("Not incorporating filter response")
        end
    end

    # Determine signal power
    signal_power = abs( spectrum[idx] )^2

    # Determine noise power
    noise_bins_Low  = spectrum[idx_Low : idx-1]
    noise_bins_High = spectrum[idx+1   : idx_High]
    noise_bins      = abs([noise_bins_Low[:], noise_bins_High[:]])
    noise_power     = sum(noise_bins .^2) / length(noise_bins)

    # Calculate statistic
    continuous_distribution = FDist(2, 2*length(noise_bins))
    statistic = ccdf(continuous_distribution, signal_power / noise_power)

    # Return SNR
    snr = (signal_power / noise_power)
    snrDb = 10 * log10(snr)

    if verbose
        println("Frequencies = [$(freq_of_interest), ",
                               "$(freq_of_interest - side_freq), ",
                               "$(freq_of_interest + side_freq)]")
        println("Indicies    = [$(idx), ",
                               "$(idx_Low), ",
                               "$(idx_High)]")
        println("Bins below = $(idx - idx_Low-1) and above = $(idx_High - idx-1)")
        #Approx correct compared to matlab. Slight differences
        println(" ")
        println("Signal  = $(signal_power)")
        println("Noise   = $(noise_power)")
        println("SNR     = $(snr)")
        println("SNR dB  = $(snrDb)")
        println("Statistic = $(statistic)")
    end

    return snrDb, signal_power, noise_power, statistic
end


#######################################
#
# Global field power
#
#######################################

function gfp(x::Array; verbose::Bool=false)

    samples, sensors = size(x)

    if verbose
        println("Computing global field power for $sensors sensors and $samples samples")
        p = Progress(samples, 1, "  Global FP...  ", 50)
    end

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
        if verbose; next!(p); end
    end

    return result
end



