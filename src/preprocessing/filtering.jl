function filterdelay(fobj::Vector)
    return (length(fobj) - 1) ÷ 2
end


function default_fir_filterorder(responsetype::FilterType, samplingrate::Number)
    # filter settings are the same as firfilt eeglab plugin (Andreas Widmann) and MNE Python. 
    # filter order is set to 3.3 times the reciprocal of the shortest transition band 
    # transition band is set to either
    # min(max(l_freq * 0.25, 2), l_freq)
    # or 
    # min(max(h_freq * 0.25, 2.), nyquist - h_freq)
    # 
    # That is, 0.25 times the frequency, but maximally 2Hz
    %

    transwidthratio = 0.25 # magic number from firfilt eeglab plugin
    fNyquist = samplingrate ./ 2
    cutOff = responsetype.w * samplingrate
    # what is the maximal filter width we can have
    if typeof(responsetype) <: Highpass
        maxDf = cutOff

        df = minimum([maximum([maxDf * transwidthratio, 2]), maxDf])

    elseif typeof(responsetype) <: Lowpass
        #for lowpass we have to look back from nyquist
        maxDf = fNyquist - cutOff
        df = minimum([maximum([cutOff * transwidthratio, 2]), maxDf])

    end

    filterorder = 3.3 ./ (df ./ samplingrate)
    filterorder = Int(filterorder ÷ 2 * 2) # we need even filter order
    return filterorder
end


#######################################
#
# Filter compensation
#
#######################################

function compensate_for_filter(d::Dict, spectrum::AbstractArray, fs::Real)
    frequencies = range(0, stop = 1, length = Int(size(spectrum, 1))) * fs / 2

    key_name = "filter"
    key_numb = 1
    key = string(key_name, key_numb)

    while haskey(d, key)

        spectrum = compensate_for_filter(d[key], spectrum, frequencies, fs)

        @debug("Accounted for $key response in spectrum estimation")

        key_numb += 1
        key = string(key_name, key_numb)
    end

    return spectrum
end


"""
    compensate_for_filter(filter::FilterCoefficients, spectrum::AbstractArray, frequencies::AbstractArray, fs::Real)

Recover the spectrum of signal by compensating for filtering done.

# Arguments

* `filter`: The filter used on the spectrum
* `spectrum`: Spectrum of signal
* `frequencies`: Array of frequencies you want to apply the compensation to
* `fs`: Sampling rate

# Returns

Spectrum of the signal after comensating for the filter
"""
function compensate_for_filter(
    filter::FilterCoefficients,
    spectrum::AbstractArray,
    frequencies::AbstractArray,
    fs::Real,
)
    filter_response = [freqresp(filter, f * ((2pi) / fs)) for f in frequencies]

    for f = 1:length(filter_response)
        spectrum[f, :, :] = spectrum[f, :, :] ./ abs.(filter_response[f])^2
    end

    return spectrum
end
