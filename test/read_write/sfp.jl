using EEG
using Base.Test
using Logging
using MAT, BDF
using SIUnits, SIUnits.ShortUnits
using FileFind

Logging.configure(level=DEBUG)


fname = joinpath(dirname(@__FILE__), "..", "data", "test.sfp")

s = read_sfp(fname)

@test length(s.x)  == 3
@test s.label == ["Fp1", "Fpz", "Fp2"]
@test s.x == [-27.747648, -0.085967, 27.676888]
@test s.y == [98.803864, 103.555275, 99.133354]
@test s.z == [34.338360, 34.357265, 34.457005]
@test s.coord_system == "Cartesian"
@test s.kind == "EEG"
