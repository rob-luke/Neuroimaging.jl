"""
A Julia package for process neuroimaing data.
"""
module Neuroimaging

using Logging,
    Unitful,
    DataFrames,
    Distances,
    CSV,
    DelimitedFiles,
    DSP,
    Distributions,
    Plots,
    MAT,
    RecipesBase,
    Printf,
    Statistics,
    FFTW,
    DataDeps,
    LinearAlgebra,
    Images,
    BDF


using Unitful: AbstractQuantity


export new_processing_key,
    find_keys_containing,
    fileparts,
    add_dataframe_static_rows,
    _find_closest_number_idx,
    # File type reading and writing
    import_biosemi,
    channelNames_biosemi_1020,
    create_channel,
    create_events,
    NeuroimagingMeasurement,
    read_avr,
    read_bsa,
    read_dat,
    read_sfp,
    read_elp,
    write_dat,
    prepare_dat,
    write_avr,
    read_evt,
    read_rba_mat,
    # Pre-processing
    epoch_rejection,
    channel_rejection,
    filterdelay,
    default_fir_filterorder,
    filter_highpass,
    filter_lowpass,
    filter_bandpass,
    filter,
    compensate_for_filter,
    remove_template,
    rereference,
    clean_triggers,
    validate_triggers,
    extra_triggers,
    downsample,
    # Reshaping of data
    extract_epochs,
    average_epochs,
    create_sweeps,
    # Statistics
    ftest,
    gfp,
    # Type - Volume Image
    VolumeImage,
    read_VolumeImage,
    plot,
    plot!,
    normalise,
    find_dipoles,
    std,
    mean,
    isequal,
    ==,
    # Type - EEG
    EEG,
    GeneralEEG,
    SSR,
    samplingrate,
    data,
    times,
    modulationrate,
    channelnames,
    read_SSR,
    TR,
    read_TR,
    trim_channel,
    add_triggers,
    remove_channel!,
    keep_channel!,
    add_channel,
    assr_frequency,
    save_results,
    trigger_channel,
    write_SSR,
    merge_channels,
    hcat,
    # Source analysis
    Sensor,
    sensors,
    Electrode,
    elecrodes,
    label,
    labels,
    x,
    y,
    z,
    show,
    match_sensors,
    EEG_64_10_20,
    EEG_Vanvooren_2014,
    EEG_Vanvooren_2014_Left,
    EEG_Vanvooren_2014_Right,
    read_EEG,
    Coordinate,
    SPM,
    BrainVision,
    Talairach,
    UnknownCoordinate,
    convert,
    conv_bv2tal,
    conv_spm_mni2tal,
    Dipole,
    best_dipole,
    Leadfield,
    match_leadfield,
    find_location,
    project,
    euclidean,
    # Plotting
    plot,
    oplot,
    plot_dat,
    plot_spectrum,
    oplot_dipoles,
    SSR_spectrogram,
    plot_filter_response,
    plot_ftest,
    Source,
    Detector,
    Optode


# Helper functions
include("miscellaneous/helper.jl")
include("datasets/datasets.jl")

# Pre-processing
include("preprocessing/data_rejection.jl")
include("preprocessing/filtering.jl")
include("preprocessing/reference.jl")
include("preprocessing/triggers.jl")

# Reshaping of data
include("reshaping/epochs.jl")
include("reshaping/sweeps.jl")

# Statistics
include("statistics/ftest.jl")
include("statistics/gfp.jl")

# Type - Neuroimaging
include("types/NeuroimagingMeasurement.jl")

# Type - Coordinates
include("types/Coordinates/Coordinates.jl")

# Type - Sensors
include("types/Sensors/Sensors.jl")

# Type - EEG
include("types/EEG/EEG.jl")
include("types/EEG/Preprocessing.jl")

# Type - SSR
include("types/SSR/SSR.jl")
include("types/SSR/Preprocessing.jl")
include("types/SSR/ReadWrite.jl")
include("types/SSR/Reshaping.jl")
include("types/SSR/Statistics.jl")
include("types/SSR/Plotting.jl")

# Type - TR
include("types/TransientResponse/TR.jl")

# Type - Dipole
include("types/Dipole/Dipole.jl")
include("types/Dipole/Operations.jl")


include("types/Sensors/Operations.jl")
include("types/Sensors/Sets.jl")
include("types/Coordinates/Operations.jl")

# Source analysis
include("source_analysis/dipoles.jl")

# Type - Leadfield
include("types/Leadfield/Leadfield.jl")
include("types/Leadfield/Operations.jl")

# Type - Volume Image
include("types/VolumeImage/VolumeImage.jl")
include("types/VolumeImage/ReadWrite.jl")
include("types/VolumeImage/Plotting.jl")
include("types/VolumeImage/Dipoles.jl")
include("types/VolumeImage/Operations.jl")

# Plotting functions
include("plotting/plots.jl")
include("types/Dipole/Plotting.jl")

# File type reading and writing
include("read_write/avr.jl")
include("read_write/bdf.jl")
include("read_write/bsa.jl")
include("read_write/dat.jl")
include("read_write/elp.jl")
include("read_write/evt.jl")
include("read_write/rba.jl")
include("read_write/sfp.jl")

end # module
