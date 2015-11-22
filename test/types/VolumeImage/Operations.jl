fname = joinpath(dirname(@__FILE__), "../../data", "test-3d.dat")

t = read_VolumeImage(fname)

@test maximum(t) == 33.2692985535
@test minimum(t) == -7.5189352036

b = t * 2

@test b.data[1, 1, 1] == 2 * b.data[1, 1, 1]
@test b.data[2, 2, 2] == 2 * b.data[2, 2, 2]

c = mean([b, t])

@test size(c.data) == size(b.data)
@test c.data[1, 1, 1] == (b.data[1, 1, 1] + t.data[1, 1, 1]) / 2

@test maximum([b, t]) == maximum(t) * 2
@test minimum([b, t]) == minimum(b)

n = normalise([b, t])

@test maximum(n) <= 1.0
@test minimum(n) >= -1.0

t2 = deepcopy(t); t2.x = t2.x[1:3]
@test_throws KeyError EEG.dimensions_equal(t, t2)
t2 = deepcopy(t); t2.y = t2.y[1:3]
@test_throws KeyError EEG.dimensions_equal(t, t2)
t2 = deepcopy(t); t2.z = t2.z[1:3]
@test_throws KeyError EEG.dimensions_equal(t, t2)
t2 = read_VolumeImage(joinpath(dirname(@__FILE__), "../../data", "test-4d.dat"))
@test_throws KeyError EEG.dimensions_equal(t, t2)
