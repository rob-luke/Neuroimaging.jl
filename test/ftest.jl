using EEG
using Base.Test

fname = joinpath(dirname(@__FILE__), "data", "test.bdf")

s = read_ASSR(fname)

@test_approx_eq_eps maximum(s.data[:,2])   54.5939 0.1
@test_approx_eq_eps minimum(s.data[:,4]) -175.2503 0.1

s = rereference(s, "Cz")

s = extract_epochs(s)

s = create_sweeps(s, epochsPerSweep=4)

snrDb, signal_power, noise_power, statistic = ftest(s.processing["sweeps"], 40.0391, 8192, side_freq=2.5)

@test_approx_eq_eps snrDb     [NaN, -7.0915, -7.8101, 2.6462, -10.2675, -4.1863] 0.001
@test_approx_eq_eps statistic [NaN,  0.8233,  0.8480, 0.1721,   0.9105,  0.6854] 0.001

s = ftest(s, 19.5, side_freq=2.5)

@test_approx_eq_eps s.processing["ftest1"][:SNRdB] [NaN, -1.2386, 0.5514, -1.5537, -2.7541, -6.7079] 0.001

s = rereference(s, "car")

s = highpass_filter(s, cutOff=2, order=1)

remove_channel!(s, ["Cz", "_4Hz_SWN_70dB_R", "20Hz_SWN_70dB_R", "10Hz_SWN_70dB_R", "80Hz_SWN_70dB_R"])

s = extract_epochs(s)

s = create_sweeps(s, epochsPerSweep=4)

s = ftest(s, 40.0391, side_freq=2.5)

@test_approx_eq_eps s.processing["ftest2"][:SNRdB] [3.2826] 0.002

println()
println("!! F test passed !!")
println()
