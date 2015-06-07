using EEG, Logging
using Base.Test

Logging.configure(level=DEBUG)

fname = joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)


#
# extract_epochs
# --------------
#

s = extract_epochs(s)

@test size(s.processing["epochs"]) == (8388,28,6)

s = extract_epochs(s, valid_triggers=[1, 2])

@test size(s.processing["epochs"]) == (8388,28,6)

s = extract_epochs(s, valid_triggers = [1])

@test size(s.processing["epochs"]) == (16776,14,6)

s = extract_epochs(s, valid_triggers = 1)

@test size(s.processing["epochs"]) == (16776,14,6)

@test_throws ErrorException extract_epochs(s, valid_triggers = -4)

