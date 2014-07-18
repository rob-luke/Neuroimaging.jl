using EEG
using Base.Test

# Tollerances to known truth are quite loose now.
# Plan to tighten them up once all functions are known to generally work

#=fname = "./data/test.bdf"=#
fname = joinpath(dirname(@__FILE__), "data", "test.bdf")

s = read_ASSR(fname, verbose=true)

@test_approx_eq_eps maximum(s.data[:,1])  189.5628662109 1
@test_approx_eq_eps minimum(s.data[:,1]) -231.6254425049 1

s = highpass_filter(s, cutOff=2, order=1, verbose=true, t=1)
#TODO: Make zero phase filter correctly account for transient period

@test_approx_eq_eps maximum(s.data[:,1])  189.5628662109  2
@test_approx_eq_eps minimum(s.data[:,1]) -231.6254425049  2

s = proc_reference(s, "Cz", verbose=true)

s = extract_epochs(s, verbose=true)

s = create_sweeps(s, epochsPerSweep=4, verbose=true)

s = ftest(s, 40.0391,  verbose=true, side_freq=0.93)

@test_approx_eq_eps s.processing["ftest1"][:SNRdB][2] -7.0911276992  0.5
@test_approx_eq_eps s.processing["ftest1"][:SNRdB][4]  2.6475683453  0.5

println()
println()
println("!! All tests passed !!")
println()
println()
