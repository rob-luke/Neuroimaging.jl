module EEG

using Logging  # For user feedback
using Docile   # For documentation
using Compat   # For backward julia compatability
using SIUnits  # Smarter units
using SIUnits.ShortUnits
using Synchrony
using DataFrames
using Distances
using ProgressMeter
using AWS
using AWS.S3
using BDF
using DSP
using Distributions
using Winston, Gadfly
using MinMaxFilter
using BDF
using MAT


export # Helper functions
       append_strings,
       new_processing_key,
       find_keys_containing,
       fileparts,
       add_dataframe_static_rows,
       _find_closest_number_idx,
       # File type reading and writing
       import_biosemi,
       channelNames_biosemi_1020,
       create_channel,
       create_events,
       read_avr,
       read_bsa,
       read_dat,
       read_sfp,
       #read_elp,
       write_dat,
       prepare_dat,
       write_avr,
       read_evt,
       read_rba_mat,
       # Pre-processing
       epoch_rejection,
       channel_rejection,
       highpass_filter,
       lowpass_filter,
       bandpass_filter,
       compensate_for_filter,
       remove_template,
       rereference,
       clean_triggers,
       validate_triggers,
       extra_triggers,
       # Reshaping of data
       extract_epochs,
       average_epochs,
       create_sweeps,
       # Statistics
       ftest,
       gfp,
       # Synchrony
       phase_lag_index,
       save_synchrony_results,
       # Type - SSR
       SSR,
       samplingrate,
       modulationrate,
       read_SSR,
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
       bootstrap,
       # Source analysis
       Electrodes,
           show,
           match_sensors,
       EEG_64_10_20,
       EEG_Vanvooren_2014,
       EEG_Vanvooren_2014_Left,
       EEG_Vanvooren_2014_Right,
       Coordinate,
           SPM,
           BrainVision,
           Talairach,
       convert,
       conv_bv2tal,
       conv_spm_mni2tal,
       beamformer_lcmv,
       Dipole,
       find_dipoles,
       best_dipole,
       orient_dipole,
       best_ftest_dipole,
       match_leadfield,
       find_location,
       project,
       # Plotting
       oplot,
       plot_dat,
       plot_spectrum,
       plot_timeseries,
       oplot_dipoles,
       SSR_spectrogram,
       plot_filter_response,
       plot_ftest



@document(manual = ["../doc/manual.md"])


# Helper functions
include("miscellaneous/helper.jl")

# File type reading and writing
include("read_write/read.jl")
include("read_write/write.jl")
include("read_write/biosemi.jl")
include("read_write/besa.jl")
include("read_write/rba.jl")

# Pre-processing
include("preprocessing/data_rejection.jl")
include("preprocessing/filtering.jl")
include("preprocessing/reference.jl")
include("preprocessing/triggers.jl")
include("reshaping/epochs.jl")
include("reshaping/sweeps.jl")

# Statistics
include("statistics/ftest.jl")
include("statistics/gfp.jl")

# Synchrony
include("synchrony/phase_lag_index.jl")

# Type - SSR
include("types/SSR/SSR.jl")
include("types/SSR/Preprocessing.jl")
include("types/SSR/ReadWrite.jl")
include("types/SSR/Reshaping.jl")
include("types/SSR/Statistics.jl")
include("types/SSR/Synchrony.jl")

# Source analysis
include("source_analysis/sensors.jl")
include("source_analysis/spatial_coordinates.jl")
include("source_analysis/beamformers.jl")
include("source_analysis/dipoles.jl")
include("source_analysis/leadfield.jl")
include("source_analysis/projection.jl")

# Plotting functions
include("plotting/plot.jl")

end # module
