module EEGjl

export
    proc_hp,
    proc_rereference,
    proc_epochs,
    proc_epoch_rejection,
    proc_sweeps,
    proc_ftest,
    plot_spectrum,
    plot_timeseries,
    plot_timeseries_multichannel,
    oplot_dipoles,
    read_bsa,
    Dipoles,
    conv_bv2tal,
    conv_spm_mni2tal

include("read.jl")
include("plot.jl")
include("processing.jl")
include("convert.jl")

end
