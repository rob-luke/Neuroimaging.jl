#######################################
#
# Test dipole orientation
#
#######################################

fname = joinpath(dirname(@__FILE__), "..", "data", "test_Hz19.5-testing.bdf")

a = read_SSR(fname)

a = add_channel(a, orient_dipole(a.data[:,1:3], a.triggers,  int(a.samplingrate), a.modulationrate, epochsPerSweep = 6), "Optimised")

a = add_channel(a, best_ftest_dipole(a.data[:,1:3], a.triggers,  int(a.samplingrate), a.modulationrate, epochsPerSweep = 6), "Best")



#
# Test dipole finding
#

fname = joinpath(dirname(@__FILE__), "../data", "test-3d.dat")

t = read_VolumeImage(fname)
dips = find_dipoles(t)

left   = Talairach(-41.81/1000, -23.69/1000, 10.37/1000)   # Average literature location
right  = Talairach( 41.81/1000, -23.69/1000, 10.37/1000)   # Average literature location
b_dip = best_dipole(left, dips)

@test euclidean(b_dip, left) == 0.023498038880581808
@test euclidean(b_dip, left) < euclidean(b_dip, right)


fname = joinpath(dirname(@__FILE__), "../data", "test-4d.dat")

t = read_VolumeImage(fname)

tmp = zeros(size(t.data, 1), size(t.data, 2), size(t.data, 3), 4*size(t.data, 4))
tmp[:, :, :, 1:2] = t.data
tmp[:, :, :, 3:4] = t.data
tmp[:, :, :, 5:6] = t.data
tmp[:, :, :, 7:8] = t.data
t.data = tmp

dips = find_dipoles(t.data, window=[3, 3, 3, 2])

@test typeof(dips) == Array{EEG.Dipole, 1}
@test length(dips) == 39

println()
println("!! Dipole test passed !!")
println()
