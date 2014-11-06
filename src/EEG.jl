module EEG

using Logging
using Docile

@docstrings [ :manual => ["../doc/manual.md"] ]

#
# File type reading and writing
#

export
    import_biosemi,
    channelNames_biosemi_1020,
    create_channel,
    create_events,
    read_avr,
    read_bsa,
    read_dat,
    read_sfp,
    read_elp,
    write_dat,
    prepare_dat,
    write_avr,
    read_evt,
    read_rba_mat
include("read_write/read.jl")
include("read_write/write.jl")
include("read_write/biosemi.jl")
include("read_write/besa.jl")
include("read_write/rba.jl")


#
# Pre-processing
#

export
    epoch_rejection,
    channel_rejection
include("preprocessing/data_rejection.jl")
export
    highpass_filter,
    lowpass_filter,
    bandpass_filter
include("preprocessing/filtering.jl")
export
    remove_template,
    rereference
include("preprocessing/reference.jl")
export
    clean_triggers,
    validate_triggers,
    extra_triggers
include("preprocessing/triggers.jl")


#
# Reshaping of data
#

export
    extract_epochs,
    average_epochs
include("reshaping/epochs.jl")
export
    create_sweeps
include("reshaping/sweeps.jl")


#
# Statistics
#

export
    ftest,
    gfp
include("statistics/ftest.jl")
include("statistics/gfp.jl")


#
# Synchrony
#

export
    phase_lag_index,
    save_synchrony_results
include("synchrony/phase_lag_index.jl")


#
# Type - SSR
#

export
    SSR,
    read_SSR,
    trim_channel,
    read_evt,
    add_triggers,
    remove_channel!,
    keep_channel!,
    add_channel,
    assr_frequency,
    bandpass_filter,
    save_results,
    trigger_channel,
    channel_rejection,
    write_SSR,
        highpass_filter,
        rereference,
        merge_channels,
        extract_epochs,
        create_sweeps
include("types/SSR.jl")


#
# Source analysis
#

export
    Electrodes,
        show,
        match_sensors,
    EEG_64_10_20,
    EEG_Vanvooren_2014,
    EEG_Vanvooren_2014_Left,
    EEG_Vanvooren_2014_Right
include("source_analysis/sensors.jl")

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
    best_dipole,
    orient_dipole,
    best_ftest_dipole
include("source_analysis/dipoles.jl")

export
    match_leadfield,
    find_location
include("source_analysis/leadfield.jl")

export
    project
include("source_analysis/projection.jl")



#
# Helper functions
#

export
    append_strings,
    new_processing_key,
    find_keys_containing,
    fileparts,
    add_dataframe_static_rows,
    _find_closest_number_idx
include("miscellaneous/helper.jl")


#
# Plotting functions
#
export
    oplot,
    plot_dat,
    oplot,
    plot_spectrum,
    plot_timeseries,
    oplot_dipoles,
    SSR_spectrogram,
    plot_filter_response
include("plotting/plot.jl")


end
