using EEG
using Base.Test
using Logging
using MAT, BDF
using SIUnits, SIUnits.ShortUnits
using FileFind
using Plots

Logging.configure(level=DEBUG)
Logging.configure(output=open("/Users/rluke/Desktop/EEG.test.log", "a"))

e = read_elp(joinpath(dirname(@__FILE__), "..", "data", "test.elp"))

@test length(e) == 2
@test e[1].label == "Fpz"
@test e[2].label == "Fp2"
