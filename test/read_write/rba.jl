a  = read_SSR(joinpath(dirname(@__FILE__), "..", "data", "test_Hz19.5-testing.bdf"))

@fact a.processing["Side"] --> "Bilateral"
@fact a.processing["Name"] --> "P2"
@fact a.processing["Amplitude"] --> 70.0
@fact a.processing["Carrier_Frequency"] --> 1000.0
@fact modulationrate(a) --> 40.0390625
