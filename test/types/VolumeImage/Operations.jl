fname = joinpath(dirname(@__FILE__), "../../data", "test-3d.dat")

t = read_VolumeImage(fname)

@test maximum(t) == 33.2692985535
@test minimum(t) == -7.5189352036
