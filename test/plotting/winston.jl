fname = joinpath(dirname(@__FILE__), "../data", "test-3d.dat")

x, y, z, s, t = read_dat(fname)

p = plot_dat(squeeze(s, 4))



