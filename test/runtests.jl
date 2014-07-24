using EEG
using Base.Test
using Logging

Logging.configure(level=INFO)

include("epochs.jl")
include("convert.jl")
include("ftest.jl")
