module EEG

# Functions
export
    read_ASSR,
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
    oplot,
    save_results

# Testing ground
export
    response,
    plot_filter_response,
    remove_channel!
    #=import_headmodel=#

# Types
export
    ASSR,
    Electrodes,
    Dipoles
    #=Coordinates,=#
        #=SPM,=#
        #=BrainVision,=#
        #=Talairach=#

# Helper functions
export
    append_strings,
    new_processing_key,
    find_keys_containing,
    fileparts

include("read.jl")
include("plot.jl")
include("processing.jl")
include("convert.jl")
include("biosemi.jl")
include("signal_processing.jl")
include("type_ASSR.jl")
#=include("type_Leadfield.jl")=#
include("helper.jl")
#=include("spatial_coordinates.jl")=#


end
