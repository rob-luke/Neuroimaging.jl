#######################################
#
# Bootstrapping
#
#######################################


@doc doc"""
Estimate the value and standard deviation of ASSR response amplitude and phase using bootstrapping on the frequency
bin across epochs.

#### Input

* `s`: Steady state response type
* `freq_of_interest`: frequency to analyse (modulation rate)
* `ID`: value to store as ID (" ")
* `data_type`: what to run the fft on (epochs)
* `fs`: sampling rate (SSR sampling rate)
* `num_resample`: number of bootstrapping interations to make (1000)
* `results_key`: Where in the processing dictionary to store results ("statistics")

#### Output

* Bootstrapping values are added to the processing key `statistics`

#### Example

```julia
s = bootstrap(s, N=100)
```
""" ->
function bootstrap(s::SSR; freq_of_interest::Union(Real, AbstractArray) = modulationrate(s), ID::String = "",
    data_type::String="epochs", fs::Number=samplingrate(s), results_key::String="statistics", kwargs...)

    if !haskey(s.processing, "epochs")
        warn("You need to calculate epochs to create sweeps. Doing this for you.")
        s = extract_epochs(s; kwargs...)
    end

    for freq in freq_of_interest

        debug("Bootstrapping SSR at $freq Hz")

        SNRdB, SNRdB_SD, pha, pha_SD, amp, amp_SD, noi, noi_SD, actual_freq = bootstrap(s.processing[data_type], freq, fs, s.processing; kwargs...)

        result = DataFrame( ID                  = vec(repmat([ID], length(s.channel_names), 1)),
                            Channel             = copy(s.channel_names),
                            ModulationRate      = copy(modulationrate(s)),
                            AnalysisType        = "Bootstrapping",
                            AnalysisFrequency   = actual_freq,
                            SignalAmplitude     = vec(amp),
                            SignalAmpltiude_SD  = vec(amp_SD),
                            SignalPhase         = vec(pha),
                            SignalPhase_SD      = vec(pha_SD),
                            NoiseAmplitude      = vec(noi),
                            NoiseAmplitude_SD   = vec(noi_SD),
                            SNRdB               = vec(SNRdB),
                            SNRdB_SD            = vec(SNRdB_SD))

        result = add_dataframe_static_rows(result, kwargs)

        if haskey(s.processing, results_key)
            s.processing[results_key] = vcat(s.processing[results_key], result)
        else
            s.processing[results_key] = result
        end
    end

    return s
end

function bootstrap(s::SSR, freq_of_interest::Union(Real, AbstractArray); kwargs...)

    bootstrap(s, freq_of_interest=freq_of_interest; kwargs...)
end


# Generate random selection with replacement for bootstrapping
function generate_sample_selection(N::Int)
    int(round(rand(N) * (N-1) + 1))
end


# Internal function for calculating the bootstrapping
function bootstrap{T <: FloatingPoint}(epochs::Array{T,3}, freq::Number, fs::Number, processing::Dict;
    num_resamples::Int=1000, kwargs... )

    # Calculations and pre allocation
    len_epoch = size(epochs, 1)
    num_epoch = size(epochs, 2)
    num_chans = size(epochs, 3)
    boots_amp = Array(FloatingPoint, num_resamples, num_chans)   # Store all the bootsrapped amplitudes
    boots_pha = Array(FloatingPoint, num_resamples, num_chans)   # Store all the bootsrapped phases
    boots_noi = Array(FloatingPoint, num_resamples, num_chans)   # Store all the bootsrapped noises
    boots_snr = Array(FloatingPoint, num_resamples, num_chans)   # Store all the bootsrapped snrs

    # Calculate spectrum to bootstrap on. This is faster than randomising the epochs and calculating an FFT each time
    spectrum = (2 / len_epoch) * fft(epochs, 1)[1:len_epoch / 2 + 1, :, :]
    spectrum = compensate_for_filter(processing, spectrum, fs)
    frequencies = linspace(0, 1, size(spectrum, 1)) * fs / 2

    # Reduce the spectrum to just the frequency of interest
    idx = _find_closest_number_idx(frequencies, freq)
    spectrum = squeeze(spectrum[idx, :, :], 1)

    for n in 1:num_resamples

        # Generate a sample spectrum using selection with replacement
        tmp_spec = spectrum[generate_sample_selection(num_epoch), :]
        tmp_spec_mean = mean(tmp_spec, 1)

        for c in 1:num_chans

            # Calculate the phase and amplitude for this realisation
            boots_amp[n, c] = abs(tmp_spec_mean[:, c])[1]
            boots_pha[n, c] = angle(tmp_spec_mean[:, c])[1]
            boots_noi[n, c] = std([tmp_spec[:, c], tmp_spec_mean[:, c]]) / sqrt(size(tmp_spec, 1))
            boots_snr[n, c] = (boots_amp[n, c] .^2) / real(boots_noi[n, c] .^2)
        end
    end

    # Plotting code to view the distribution of values found, use to check its normally distributed
    #
    # filename = "histogram"
    # while isreadable(string(filename, ".pdf"))
    #     filename = string(filename, "1")
    # end
    # p = Gadfly.plot(x=boots_amp[:, 1], Gadfly.Geom.histogram)
    # Gadfly.draw(Gadfly.PDF(string(filename, ".pdf"), 8inch, 8inch), p)

    # TODO Check the types and why forcing is needed

    return 10 * log10( mean(boots_snr, 1)), float(10 * log10( std(boots_snr, 1))), mean(boots_pha, 1), std(boots_pha, 1),
           mean(boots_amp, 1), std(boots_amp, 1), mean(boots_noi, 1), std(boots_noi, 1), frequencies[idx]
end



#######################################
#
# FTest
#
#######################################


function ftest(s::SSR; freq_of_interest::Union(Real, AbstractArray)=modulationrate(s), side_freq::Number=0.5,
    ID::String="", spill_bins::Int=2, results_key::String="statistics", kwargs... )

    # Do calculation here once, instead of in each low level call
    spectrum    = EEG._ftest_spectrum(s.processing["sweeps"])
    spectrum    = compensate_for_filter(s.processing, spectrum, samplingrate(s))
    frequencies = linspace(0, 1, int(size(spectrum, 1)))*samplingrate(s)/2

    for freq in freq_of_interest

        snrDb, phase, signal, noise, statistic = ftest(spectrum, frequencies, freq, side_freq, spill_bins)

        result = DataFrame(ID                 = vec(repmat([ID], length(s.channel_names), 1)),
                           Channel            = copy(s.channel_names),
                           ModulationRate     = copy(modulationrate(s)),
                           AnalysisType       = "F-test",
                           AnalysisFrequency  = freq,
                           SignalPower        = vec(signal),
                           SignalPhase        = vec(phase),
                           NoisePower         = vec(noise),
                           SNRdB              = vec(snrDb),
                           Statistic          = vec(statistic))

        result = add_dataframe_static_rows(result, kwargs)

        if haskey(s.processing, results_key)
            s.processing[results_key] = vcat(s.processing[results_key], result)
        else
            s.processing[results_key] = result
        end

    end

    return s
end


# Backward compatibility
function ftest(s::SSR, freq_of_interest::Array; kwargs...)

    ftest(s, freq_of_interest = freq_of_interest; kwargs...)
end


#######################################
#
# Helper functions
#
#######################################


# Save ftest results to file
function save_results(a::SSR; name_extension::String="", kwargs...)

    file_name = string(a.file_name, name_extension, ".csv")

    # Rename to save space
    results = a.processing

    # Index of keys to be exported
    result_idx = find_keys_containing(results, "ftest")
    result_idx = [result_idx, find_keys_containing(results, "hotelling")]

    if length(result_idx) > 0

        to_save = get(results, collect(keys(results))[result_idx[1]], 0)

        if length(result_idx) > 1
            for k = result_idx[2:end]
                result_data = get(results, collect(keys(results))[k], 0)
                to_save = vcat(to_save, result_data)
            end
        end

    writetable(file_name, to_save)
    end

    info("File saved to $file_name")

    return a
end
