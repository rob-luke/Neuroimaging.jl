fname = joinpath(dirname(@__FILE__), "../../data", "test-4d.dat")

t = read_VolumeImage(fname)
dips = find_dipoles(mean(t))
@test size(dips) == (1,3)


fname = joinpath(dirname(@__FILE__), "../../data", "test-3d.dat")

t = read_VolumeImage(fname)
dips = find_dipoles(mean(t))
@test size(dips) == (1,9)

println()
println("!! Volume image dipole test passed !!")
println()