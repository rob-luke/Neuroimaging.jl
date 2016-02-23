# Generate random leadfield
L = Leadfield(rand(2000, 3, 6), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(["Cz","80Hz_SWN_70dB_R","20Hz_SWN_70dB_R","40Hz_SWN_70dB_R","10Hz_SWN_70dB_R","_4Hz_SWN_70dB_R"]))
show(L)
@test size(L.L) == (2000, 3, 6)

s = read_SSR(joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-testing.bdf"))

L1 = match_leadfield(L, s)
@test size(L1.L) == (2000, 3, 6)

keep_channel!(s, ["Cz","80Hz_SWN_70dB_R","20Hz_SWN_70dB_R","40Hz_SWN_70dB_R"])
L2 = match_leadfield(deepcopy(L), s)
@test size(L2.L) == (2000, 3, 4)
@test L2.L[:, :, 1] == L1.L[:, :, 1]
@test L2.L[:, :, 2] == L1.L[:, :, 3]
@test L2.L[:, :, 4] == L1.L[:, :, 6]
@test L2.sensors == s.channel_names

s = merge_channels(s, "Cz", "garbage")
@test_throws BoundsError match_leadfield(L, s)

# Generate random leadfield
L = Leadfield(rand(2000, 3, 5), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(rand(2000, 1)), vec(["Cz","80Hz_SWN_70dB_R","10Hz_SWN_70dB_R","_4Hz_SWN_70dB_R"]))
@test_throws ErrorException  match_leadfield(L, s)
