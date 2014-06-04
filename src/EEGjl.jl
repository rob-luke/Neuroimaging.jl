module EEGjl

# Functions
export
    read_EEG,
    channelNames_biosemi_1020,
    proc_hp,
    remove_template,
    proc_reference,
    extract_epochs,
    create_sweeps,
    proc_epoch_rejection,
    ftest,
    plot_spectrum,
    plot_timeseries,
    oplot_dipoles,
    read_bsa,
    conv_bv2tal,
    conv_spm_mni2tal,
    read_dat,
    plot_dat,
    read_sfp,
    oplot

# Testing ground
export
    response,
    plot_filter_response,
    import_headmodel

# Types
export
    ASSR,
    Electrodes,
    Dipoles

# Helper functions
export
    append_strings

include("read.jl")
include("plot.jl")
include("processing.jl")
include("convert.jl")
include("biosemi.jl")
include("signal_processing.jl")
include("type_ASSR.jl")
include("type_Leadfield.jl")

end
