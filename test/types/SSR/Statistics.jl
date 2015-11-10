fname = joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)
s.modulationrate = 19.5
s = bootstrap(s, num_resamples = 5000)

# Use approx equal as the bootstrapping varies due to the random sampling
@test_approx_eq_eps s.processing["statistics"][:SNRdB] [2.345, 4.327, 1.487, 2.487, 2.749, 2.175] 1.0
@test_approx_eq_eps s.processing["statistics"][:SNRdB_SD] [2.415, 2.936, 1.707, 2.556, 2.655, 2.228] 1.0

