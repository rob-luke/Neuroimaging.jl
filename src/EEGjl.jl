module EEGjl

export
    proc_hp,
    remove_template,
    proc_reference,
    proc_epochs,
    extract_epochs,
    create_sweeps,
    proc_epoch_rejection,
    proc_sweeps,
    proc_ftest,
    plot_spectrum,
    plot_timeseries,
    oplot_dipoles,
    read_bsa,
    conv_bv2tal,
    conv_spm_mni2tal,
    read_dat,
    plot_dat,
    read_sfp,
    oplot,
    channelNames_biosemi_1020,
    read_EEG


export
    EEG,
    Electrodes,
    Dipoles

include("read.jl")
include("plot.jl")
include("processing.jl")
include("convert.jl")
include("biosemi.jl")
include("eegtype.jl")

end
