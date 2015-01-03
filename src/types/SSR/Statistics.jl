#######################################
#
# Statistics
#
#######################################


function ftest(a::SSR; freq_of_interest::Union(Real, AbstractArray)=float(a.modulation_frequency),
                side_freq::Number=0.5, ID::String="", spill_bins::Int=2, kwargs... )


    # Do calculation here once, instead of in each low level call
    spectrum    = EEG._ftest_spectrum(a.processing["sweeps"])
    spectrum    = compensate_for_filter(a.processing, spectrum, float(a.samplingrate))
    frequencies = linspace(0, 1, int(size(spectrum, 1)))*float(a.samplingrate)/2

    for freq in freq_of_interest

        snrDb, phase, signal, noise, statistic = ftest(spectrum, frequencies, freq, side_freq, spill_bins)

        result = DataFrame(
                            ID                  = vec(repmat([ID], length(a.channel_names), 1)),
                            Channel             = copy(a.channel_names),
                            ModulationFrequency = copy(float(a.modulation_frequency)),
                            AnalysisType        = "ftest",
                            AnalysisFrequency   = freq,
                            SignalPower         = vec(signal),
                            SignalPhase         = vec(phase),
                            NoisePower          = vec(noise),
                            SNRdB               = vec(snrDb),
                            Statistic           = vec(statistic)
                          )

        result   = add_dataframe_static_rows(result, kwargs)
        key_name = new_processing_key(a.processing, "ftest")
        merge!(a.processing, @compat Dict(key_name => result) )

    end

    return a
end


# Backward compatibility
function ftest(a::SSR, freq_of_interest::Array; kwargs...)

    ftest(a, freq_of_interest = freq_of_interest; kwargs...)
end


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
                to_save = rbind(to_save, result_data)
            end
        end

    writetable(file_name, to_save)
    end

    info("File saved to $file_name")

    return a
end
