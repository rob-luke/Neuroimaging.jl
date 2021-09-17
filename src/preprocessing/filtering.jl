
	
	
	
	function filter(obj::NeuroimagingMeasurement,responsetype::FilterType; kwargs...)
		# Afaik there is a discussion going on, whether such error messages should be provided or not. I think I like that this is here, because you need less julia knowledge to understand what is wrong
		error("Currently no filter defaults implemented for $(typeof(obj)), please see the documentation how to define your own filter or raise an issue on GitHub.")
	end
	
	# Modality independent filtering
	function filter(
			obj::NeuroimagingMeasurement,
			responsetype::FilterType,
			designmethod;kwargs...
			)		
		
		fobj = digitalfilter(responsetype,designmethod)
        obj2 = deepcopy(obj) # TODO: Not sure if this is the proper way to make sure data is not overwritten inplace
		obj2.data = filter(obj2.data,fobj;kwargs...)
		return obj2
	end
		
	function filter(s,fobj; filtfilt=false)
        
		if filtfilt
			#filtfilt automatically compensates for grpdelay
			s = DSP.filtfilt(fobj,s)
		else
			# append filterdelay as zeros
			tau = filterdelay(fobj)
            if ndims(s) >1 # todo: this feels hacky
                # we want to add zeros at the end to get a longer signal for the filter, so that we can then correct the filter delay
                s_dim2 = size(s)[2]
            else
                s_dim2 = 1
            end
			s = vcat(s,zeros(tau*2,s_dim2))
            
			
			# filter
			s = filt(fobj,s)
			
			# fix grpdelay
			s = s[tau+1:end-tau,:]
			
		end
		return s
	end
	function filterdelay(fobj::Vector) 
        return (length(fobj)-1)÷2
    end
    function filterdelay(fobj::ZeroPoleGain)
        # Todo: This is unsatisfactory, but maybe necessary?
        error("Butterworth has non-linear phase, use filtfilt=true to compensate delay")
    end

	function  default_fir_filterorder(responsetype,samplingrate)
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
			
				df = minimum([maximum([maxDf * transwidthratio, 2]), maxDf]);

			elseif typeof(responsetype) <: Lowpass
				#for lowpass we have to look back from nyquist
				maxDf = fNyquist - cutOff
				df = minimum([maximum([cutOff * transwidthratio, 2]), maxDf]);

			end
			
			filterorder = 3.3 ./ (df ./ samplingrate) 
			filterorder = Int(filterorder ÷ 2 * 2) # we need even filter order
		return filterorder
	end

"""
    filter_highpass(filter_highpass(obj::NeuroimagingMeasurement ,cutOff;kwargs...)

High pass filter, group delay corrected. Modality specific defaults are applied

# Arguments

* `obj`: NeuroimagingMeasurement
* `cutOff`: Cut off frequency in Hz
* `kwargs...` passed on to filter

# Returns

* filtered NeuroimagingMeasurement
"""
function filter_highpass(obj::NeuroimagingMeasurement ,cutOff;kwargs...)
    responsetype = Highpass(cutOff,fs=samplingrate(obj))
    return filter(obj,responsetype;kwargs...)
end


"""
    filter_lowpass(filter_highpass(obj::NeuroimagingMeasurement ,cutOff;kwargs...)

Low pass filter, group delay corrected. Modality specific defaults are applied

# Arguments

* `obj`: NeuroimagingMeasurement
* `cutOff`: Cut off frequency in Hz
* `kwargs...` passed on to filter

# Returns

* filtered NeuroimagingMeasurement
"""

function filter_lowpass(obj::NeuroimagingMeasurement ,cutOff;kwargs...)
    responsetype = Lowpass(cutOff,fs=samplingrate(obj))
    return filter(obj,responsetype;kwargs...)
end


"""
    filter_bandpass

Wrapper to apply both Lowpass and Highpass. While a proper bandpass is 50% faster, this is easier for now.

# Arguments

* `obj`: NeuroimagingMeasurement
* `lowCutOff`: Lower cutOff frequency in Hz for Highpass
* `highCutOff`: Higher cutOff frequency in Hz for Lowpass


# Returns

* filtered signal
* filter used on signal

# TODO
Use filtfilt rather than custom implementation.
"""
function filter_bandpass(obj::NeuroimagingMeasurement,lowCutoff, highCutoff; kwargs...)
    obj = filter_lowpass(obj,lowCutOff;kwargs...)
    return filter_highpass(obj,highCutOff;kwargs...)
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
