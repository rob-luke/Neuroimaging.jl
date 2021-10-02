#######################################
#
# FTest
#
#######################################

"""
    ftest(s::SSR)
    ftest(s::SSR; kwargs...)

Run f-test statistics on steady state response measurement.

# Arguments

* `freq_of_interest`: Frequency to analyse for presence of a response
* `side_freq`: Adjacent frequencies above and below the frequency of interest used to quantify the noise
* `ID`: Participant ID for storage in resulting dataframe
* `spill_bins`: Number of bins each side of the FFT bin of interes to ignore in noise computation
* `results_key`: Dictionary key name to store results in `s.processing`


# Examples
```julia
s = read_SSR(fname)
s.modulationrate = 33.2u"Hz"
s = ftest(s)
println(s.processing['statistics'])
```

# Reference
Hofmann, M., Wouters, J. Improved Electrically Evoked Auditory Steady-State Response Thresholds in Humans. JARO 13, 573–589 (2012). https://doi.org/10.1007/s10162-012-0321-8

Luke, Robert, and Jan Wouters. "Kalman filter based estimation of auditory steady state response parameters." IEEE Transactions on Neural Systems and Rehabilitation Engineering 25.3 (2016): 196-204.
"""
function ftest(
    s::SSR;
    freq_of_interest::Union{Real,AbstractArray} = modulationrate(s),
    side_freq::Number = 0.5,
    ID::AbstractString = "",
    spill_bins::Int = 2,
    results_key::AbstractString = "statistics",
    kwargs...,
)

    # Do calculation here once, instead of in each low level call
    spectrum = Neuroimaging._ftest_spectrum(s.processing["sweeps"])
    spectrum = compensate_for_filter(s.processing, spectrum, samplingrate(Float64, s))
    frequencies =
        range(0, stop = 1, length = Int(size(spectrum, 1))) * samplingrate(Float64, s) / 2

    for freq in freq_of_interest

        snrDb, phase, signal, noise, statistic =
            ftest(spectrum, frequencies, freq, side_freq, spill_bins)

        result = DataFrame(
            ID = vec(repeat([ID], length(channelnames(s)), 1)),
            Channel = copy(channelnames(s)),
            ModulationRate = copy(modulationrate(s)),
            AnalysisType = vec(repeat(["F-test"], length(channelnames(s)))),
            AnalysisFrequency = vec(repeat([freq], length(channelnames(s)))),
            SignalAmplitude = vec(sqrt.(signal)),
            SignalPhase = vec(phase),
            NoiseAmplitude = vec(sqrt.(noise)),
            SNRdB = vec(snrDb),
            Statistic = vec(statistic),
        )

        result = add_dataframe_static_rows(result, kwargs)

        if haskey(s.processing, results_key)
            s.processing[results_key] = vcat(s.processing[results_key], result)
        else
            s.processing[results_key] = result
        end

    end

    return s
end


#######################################
#
# Helper functions
#
#######################################

"""
Save the processing step information from SSR type.

By default saves information in the key `statistics`,
but this can be modified by the user.
"""
# Save ftest results to file
function save_results(
    a::SSR;
    name_extension::AbstractString = "",
    results_key::AbstractString = "statistics",
    kwargs...,
)

    file_name = string(a.file_name, name_extension, ".csv")

    # Rename to save space
    results = a.processing

    # Index of keys to be exported
    result_idx = find_keys_containing(results, results_key)

    if length(result_idx) > 0

        to_save = get(results, collect(keys(results))[result_idx[1]], 0)

        CSV.write(file_name, to_save)
    end

    @info("File saved to $file_name")

    return a
end
