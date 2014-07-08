module EEG

# Functions
export
    channelNames_biosemi_1020,
    proc_hp,
    remove_template,
    proc_reference,
    read_bsa,
    conv_bv2tal,
    conv_spm_mni2tal,
    read_dat,
    read_sfp,
    gfp

# Statistics
export
    ftest
include("statistics.jl")

# Epochs
export
    extract_epochs,
    proc_epoch_rejection,
    create_sweeps
include("epochs.jl")

# Testing ground

# ASSR type
export
    ASSR,
        read_ASSR,
        trim_ASSR,
        remove_channel!,
        add_channel,
        assr_frequency,
        save_results,
        write_ASSR,
            proc_hp,                # Also defined for ASSRs
            proc_reference,
            merge_channels,
            extract_epochs,
            create_sweeps
include("type_ASSR.jl")


# Electrodes
export
    Electrodes,
        show,
        match_sensors,
        readELP
include("sensors.jl")

# Source analysis
export
    beamformer_lcmv,
    plot_dat
include("source_analysis.jl")



# Type
export
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
    #=oplot_dipoles,=#
    #=ASSR_spectrogram,=#
    #=plot_filter_response=#
#=include("plot.jl")=#

include("read.jl")
include("processing.jl")
include("convert.jl")
include("biosemi.jl")
include("helper.jl")
include("signal_processing.jl")
#=include("type_Leadfield.jl")=#
#=include("spatial_coordinates.jl")=#


end
