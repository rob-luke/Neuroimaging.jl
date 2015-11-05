s = read_SSR(   joinpath(dirname(@__FILE__), "..", "data", "test_Hz19.5-testing.bdf"))
s = read_evt(s, joinpath(dirname(@__FILE__), "..", "data", "test.evt"))

