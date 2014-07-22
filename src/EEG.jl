module EEG

#
# File type reading and writing
#
export
    read_bsa,
    read_dat,
    read_sfp,
    read_elp
include("read_write/read.jl")


#
# Pre-processing
#
export
    channelNames_biosemi_1020,
    highpass_filter,
    remove_template,
    rereference
include("preprocessing/preprocessing.jl")
include("preprocessing/biosemi.jl")


#
# Epochs
#
export
    extract_epochs,
    epoch_rejection,
    create_sweeps
include("epochs.jl")


#
# Statistics
#
export
    ftest,
    gfp
include("statistics.jl")


#
# Type - ASSR
#
export
    ASSR,
    read_ASSR,
    trim_ASSR,
    remove_channel!,
    add_channel,
    assr_frequency,
    save_results,
    write_ASSR,
        highpass_filter,
        rereference,
        merge_channels,
        extract_epochs,
        create_sweeps
include("types/type_ASSR.jl")


#
# Source analysis
#
export
    Electrodes,
        show,
        match_sensors
include("sensors.jl")

export
    Coordinate,
        SPM,
        BrainVision,
        Talairach,
    convert,
    conv_bv2tal,
    conv_spm_mni2tal
include("source_analysis/spatial_coordinates.jl")

export
    beamformer_lcmv
include("source_analysis/beamformers.jl")

export
    Dipole,
    find_dipoles,
    best_dipole
include("source_analysis/dipoles.jl")

export
    match_leadfield
include("source_analysis/leadfield.jl")



#
# Helper functions
#
export
    append_strings,
    new_processing_key,
    find_keys_containing,
    fileparts
include("helper.jl")


#
# Plotting functions
# Requires Winston and is disabled until it works on travis-ci
#
#=export=#
    #=oplot,=#
    #=plot_spectrum,=#
    #=plot_timeseries,=#
    #=oplot_dipoles,=#
    #=ASSR_spectrogram,=#
    #=plot_filter_response=#
#=include("plot.jl")=#
#=export=#
    #=plot_dat,=#
    #=oplot=#

end
