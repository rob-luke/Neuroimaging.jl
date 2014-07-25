using EEG
using Base.Test
using Logging

Logging.configure(level=DEBUG)

include("epochs.jl")
include("convert.jl")
include("ftest.jl")
include("read_write.jl")
