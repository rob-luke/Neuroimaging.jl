using EEG
using Base.Test

# Tollerances to known truth are quite loose now.
# Plan to tighten them up once all functions are known to generally work

#=fname = "./data/test.bdf"=#
fname = joinpath(dirname(@__FILE__), "data", "test.bdf")

s = read_ASSR(fname, verbose=true)

@test_approx_eq_eps maximum(s.data[:,2]) 54.5939   0.1
@test_approx_eq_eps minimum(s.data[:,4]) -175.2503 0.1

s = rereference(s, "Cz", verbose=true)

s = extract_epochs(s, verbose=true)

s = create_sweeps(s, epochsPerSweep=4, verbose=true)

snrDb, signal_power, noise_power, statistic = ftest(s.processing["sweeps"], 40.0391, 8192,  verbose=true, side_freq=2.5)

@test_approx_eq_eps snrDb     [NaN, -7.0915, -7.8101, 2.6462, -10.2675, -4.1863] 0.001
@test_approx_eq_eps statistic [NaN,  0.8233,  0.8480, 0.1721,   0.9105,  0.6854] 0.001


println()
println("!! F test passed !!")
println()
