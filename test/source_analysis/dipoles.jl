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



println()
println("!! Dipole test passed !!")
println()
