a  = read_SSR(joinpath(dirname(@__FILE__), "..", "data", "test_Hz19.5-testing.bdf"))

@test a.processing["Side"] == "Bilateral"
@test a.processing["Name"] == "P2"
@test a.processing["Amplitude"] == 70.0
@test a.processing["Carrier_Frequency"] == 1000.0
@test modulationrate(a) == 40.0390625
