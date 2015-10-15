@doc """
Phase locked index of waveforms two time series cut in to epochs.

Calculated using [Synchrony.jl](https://github.com/simonster/Synchrony.jl)

#### Arguments

* `data`: samples x channels x epochs as described in [multitaper documentation](https://github.com/simonster/Synchrony.jl/blob/master/src/multitaper.jl)
* `freqrange`: range of frequencies to analyse
* `fs`: sample rate
""" ->
function phase_lag_index(data::Array, freq_of_interest::Real, fs::Real)

    err("PLI code has not been validated. Do not use")

    debug("Calculating phase lag index. Sensors:$(size(data,2)) Samples:$(size(data,1)) Epochs:$(size(data,3))")

    # between which actual frequencies are analysed
    freqrange = int(round(freq_of_interest))-2:int(round(freq_of_interest))+2
    freqs = [frequencies(data, fs, freqrange[1], freqrange[end])[1]]
    debug("PLI Target:$freq_of_interest Frequency range:$(round(freqs[1],2)):$(round(freqs[end],2))  Sample rate:$fs")

    result =  vec(multitaper(data, PLI(), freqrange=freqrange, fs))

    # find the closest frequency analysed. also check its the optimal pli
    rdiff = abs(freqs-freq_of_interest)
    idx = find(rdiff .== minimum(rdiff))
    #=r = DataFrame( freq = freqs, diff = rdiff, pli = result, pli_opt = result.-result[idx])=#
    #=debug(r)=#

    return result[idx]
end
