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

s.triggers["test"] = 1

validate_triggers(s.triggers)

s.triggers["Duration"] = s.triggers["Duration"][1:4]
s.triggers["Code"] = s.triggers["Code"][1:4]

@test_throws KeyError validate_triggers(s.triggers)
