fname = joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)
s = highpass_filter(s)
s = rereference(s, "Cz")
    keep_channel!(s, "40Hz_SWN_70dB_R")
s = extract_epochs(s)
s = bootstrap(s, num_resamples = 5000)

s = lowpass_filter(s, cutOff = 200)
s = downsample(s, 1//4)
s = extract_epochs(s)
s = bootstrap(s, num_resamples = 5000)

@test_approx_eq_eps s.processing["statistics"][:AnalysisFrequency][1] s.processing["statistics"][:AnalysisFrequency][2] 0.5
@test_approx_eq_eps s.processing["statistics"][:SNRdB][1] s.processing["statistics"][:SNRdB][2] 0.4
@test_approx_eq_eps s.processing["statistics"][:SignalAmplitude][1] s.processing["statistics"][:SignalAmplitude][2] 0.2
@test_approx_eq_eps s.processing["statistics"][:NoiseAmplitude][1] s.processing["statistics"][:NoiseAmplitude][2] 0.2

