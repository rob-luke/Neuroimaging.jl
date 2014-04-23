module EEGjl

export
    proc_hp,
    proc_rereference,
    proc_epochs,
    proc_epoch_rejection,
    proc_sweeps,
    proc_ftest,
    plot_spectrum,
    plot_timeseries

include("plot.jl")
include("processing.jl")

end
