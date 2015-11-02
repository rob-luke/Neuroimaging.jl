
using EEG
using Base.Test
using Logging
using MAT, BDF
using SIUnits, SIUnits.ShortUnits

Logging.configure(level=DEBUG)

include("miscellaneous/helper.jl")
include("plotting/ftest.jl")
include("preprocessing/data_rejection.jl")
include("preprocessing/filtering.jl")
include("reshaping/epochs.jl")
include("reshaping/sweeps.jl")
include("source_analysis/beamformers.jl")
include("source_analysis/dipoles.jl")
include("source_analysis/projection.jl")
include("convert.jl")
include("ftest.jl")
include("read_write.jl")
include("read_write/bsa.jl")
include("types/SSR/SSR.jl")
include("types/SSR/Statistics.jl")
include("types/SSR/Reshaping.jl")
include("types/SSR/Preprocessing.jl")
include("types/VolumeImage/VolumeImage.jl")
include("types/VolumeImage/Dipoles.jl")
include("types/VolumeImage/Plotting.jl")
include("types/VolumeImage/Operations.jl")
