using EEG
using Base.Test

fname = joinpath(dirname(@__FILE__), "data", "test_Hz19.5-testing.bdf")

a = read_SSR(fname)

#######################################
#
# Test beamformer
#
#######################################

x = copy(a.data')

n = randn(size(x))

H = randn(38*28*26, 3, 6)

V, N, NAI = beamformer_lcmv(x, n, H, checks=true, progress=true)

NAI = reshape(NAI, (38, 28, 26, 1))

write_dat(joinpath(dirname(@__FILE__), "data", "SA.dat"), 1:size(NAI,1), 1:size(NAI,2), 1:size(NAI,3), NAI, 1:size(NAI,4))


#######################################
#
# Test dipole orientation
#
#######################################

a = add_channel(a, orient_dipole(a.data[:,1:3], a.triggers,  int(a.samplingrate), a.modulationfreq), "Optimised")
a = add_channel(a, best_ftest_dipole(a.data[:,1:3], a.triggers,  int(a.samplingrate), a.modulationfreq), "Best")
a = extract_epochs(a)
a = create_sweeps(a)
a = ftest(a)
println(a.processing["ftest1"])



println()
println("!! Source Analysis test passed !!")
println()
