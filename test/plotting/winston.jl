fname = joinpath(dirname(@__FILE__), "../data", "test-3d.dat")

t = read_VolumeImage(fname)

f = plot_dat(squeeze(t.data), 1)

