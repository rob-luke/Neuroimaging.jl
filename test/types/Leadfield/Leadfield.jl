# Generate random leadfield
L = Leadfield(rand(2000, 3, 6), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(["Cz","80Hz_SWN_70dB_R","20Hz_SWN_70dB_R","40Hz_SWN_70dB_R","10Hz_SWN_70dB_R","_4Hz_SWN_70dB_R"]))
show(L)
@test size(L.L) == (2000, 3, 6)

s = read_SSR(joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-testing.bdf"))

L = match_leadfield(L, s)
@test size(L.L) == (2000, 3, 6)

keep_channel!(s, ["Cz","80Hz_SWN_70dB_R","20Hz_SWN_70dB_R","40Hz_SWN_70dB_R"])
L = match_leadfield(L, s)
@test size(L.L) == (2000, 3, 4)

s = merge_channels(s, "Cz", "garbage")
@test_throws BoundsError match_leadfield(L, s)

# TODO test real data

find_location(L, Talairach(0, 0, 0))
