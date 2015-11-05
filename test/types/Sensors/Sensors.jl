fname = joinpath(dirname(@__FILE__), "..", "..", "data", "test.sfp")

s = read_sfp(fname)

#
# Test show
#

show(s)


#
# Test sensor matching
#

a, b = match_sensors(s, ["Fp1", "Fp2"])


#
# Test lead field sensor matching
#



#
# Test standard electrode sets
#

@test length(EEG_64_10_20) == 64
@test length(EEG_Vanvooren_2014) == 18
@test length(EEG_Vanvooren_2014_Left) == 9
@test length(EEG_Vanvooren_2014_Right) == 9
