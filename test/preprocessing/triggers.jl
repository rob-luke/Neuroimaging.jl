fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)

s1 = deepcopy(s)
s2 = deepcopy(s)
s3 = deepcopy(s)

validate_triggers(s.triggers)

delete!(s1.triggers, "Index")

@test_throws KeyError validate_triggers(s1.triggers)

delete!(s2.triggers, "Code")

@test_throws KeyError validate_triggers(s2.triggers)

delete!(s3.triggers, "Duration")

@test_throws KeyError validate_triggers(s3.triggers)

s2 = deepcopy(s)
s2.triggers["test"] = 1
validate_triggers(s2.triggers)

s2 = deepcopy(s)
s2.triggers["Duration"] = s2.triggers["Duration"][1:4]
@test_throws KeyError validate_triggers(s2.triggers)

s2 = deepcopy(s)
s2.triggers["Code"] = s2.triggers["Code"][1:4]
@test_throws KeyError validate_triggers(s2.triggers)

s = read_SSR(fname, valid_triggers = [8])

s = read_SSR(fname, min_epoch_length = 8388)

s = read_SSR(fname, max_epoch_length = 8389)

s = read_SSR(fname)
original_length = length(s.triggers["Index"])
s = read_SSR(fname, remove_first = 10)
@test original_length - 10 == length(s.triggers["Index"])

s = read_SSR(fname, max_epochs = 12)
@test length(s.triggers["Index"]) == 12

s = read_SSR(fname)
s.triggers = extra_triggers(s.triggers, 1, 7, 0.7, samplingrate(s))
@test length(s.triggers["Index"]) == 56
