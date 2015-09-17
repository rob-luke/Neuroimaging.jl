using Winston

fname = joinpath(dirname(@__FILE__), "../../data", "test-4d.dat")

t = read_VolumeImage(fname)
dips = find_dipoles(mean(t))
show(dips)
@test size(dips) == (3,)


fname = joinpath(dirname(@__FILE__), "../../data", "test-3d.dat")

t = read_VolumeImage(fname)
dips = find_dipoles(mean(t))
show(dips)
@test size(dips) == (9,)


# Test dipoles are returned in order of size
@test issorted([dip.size for dip in dips], rev = true)


println()
println("!! Volume image dipole test passed !!")
println()