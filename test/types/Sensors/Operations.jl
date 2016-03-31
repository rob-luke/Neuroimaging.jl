fname = joinpath(dirname(@__FILE__), "..", "..", "data", "test.sfp")

s = read_sfp(fname)


#
# Test sensor matching
#

a, b = match_sensors(s, ["Fp1", "Fp2"])


#
# Test lead field sensor matching
#

L = ones(4, 3, 5)
L[:, :, 2] = L[:, :, 2] * 2
L[:, :, 3] = L[:, :, 3] * 3
L[:, :, 4] = L[:, :, 4] * 4
L[:, :, 5] = L[:, :, 5] * 5

L, idx = match_sensors(L, ["meh", "Cz", "Fp1", "Fp2", "eh"], ["Fp2", "Cz"])

@test size(L) == (4, 3, 2)
@test L[:, :, 1] == ones(4, 3) * 4
@test L[:, :, 2] == ones(4, 3) * 2
@test idx == [4, 2]
