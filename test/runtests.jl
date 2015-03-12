using EEG
using Base.Test
using Logging

Logging.configure(level=DEBUG)

include("miscellaneous/helper.jl")
include("plotting/ftest.jl")
include("preprocessing/data_rejection.jl")
include("preprocessing/filtering.jl")
include("epochs.jl")
include("convert.jl")
include("ftest.jl")
include("read_write.jl")
include("source_analysis.jl")
include("types/SSR/SSR.jl")
include("types/SSR/Statistics.jl")
