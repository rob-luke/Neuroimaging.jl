# Modality specific Default Filter
function filter(
    eeg::EEG,
    responsetype::FilterType;
    designmethod=FIRWindow(
        DSP.hamming(
            default_fir_filterorder(responsetype,samplingrate(eeg))+1
        )
    ),
    kwargs...
    )
return filter(eeg,responsetype,designmethod;kwargs...)
end
