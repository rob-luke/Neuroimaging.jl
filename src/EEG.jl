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
    read_bsa,
    conv_bv2tal,
    conv_spm_mni2tal,
    read_dat,
    read_sfp,
    save_results,
    merge_channels

# Statistics
export
    ftest
include("statistics.jl")


# Testing ground
export
    response,
    remove_channel!,
    add_channel,
    assr_frequency,
    trim_ASSR,
    write_ASSR
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

# requires Winston
#=export=#
    #=oplot,=#
    #=plot_spectrum,=#
    #=plot_timeseries,=#
    #=oplot_dipoles=#
    #=ASSR_spectrogram=#
    #=plot_filter_response,=#
#=include("plot.jl")=#

include("read.jl")
include("processing.jl")
include("convert.jl")
include("biosemi.jl")
include("type_ASSR.jl")
include("helper.jl")
include("signal_processing.jl")
#=include("type_Leadfield.jl")=#
#=include("spatial_coordinates.jl")=#


end
