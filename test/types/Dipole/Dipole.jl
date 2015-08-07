
using EEG
using Base.Test
using Logging
using MAT, BDF
using SIUnits, SIUnits.ShortUnits

Logging.configure(level=DEBUG)


fname = joinpath(dirname(@__FILE__), "../../data", "test-3d.dat")

t = read_VolumeImage(fname)
dips = find_dipoles(t)

show(dips[1])
@printf("\n\n")
show(dips)
