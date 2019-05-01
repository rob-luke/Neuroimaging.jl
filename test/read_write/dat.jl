fname = joinpath(dirname(@__FILE__), "..", "data", "test-4d.dat")
sname = joinpath(dirname(@__FILE__), "..", "data", "tmp", "same.dat")

x, y, z, s, t = read_dat(fname)

@test size(x) == (30,)
@test size(y) == (36,)
@test size(z) == (28,)
@test size(s) == (30,36,28,2)
@test size(t) == (2,)

@test maximum(x) == 72.5
@test maximum(y) == 71.220001
@test maximum(z) == 76.809998
@test maximum(s) == 0.067409396
@test maximum(t) == 0.24

@test minimum(x) == -72.5
@test minimum(y) == -103.779999
@test minimum(z) == -58.189999
@test minimum(s) == 0.0
@test minimum(t) == 0.12

write_dat(sname, x, y, z, s[:,:,:,:], t)

x2, y2, z2, s2, t2 = read_dat(sname)

@test x == x2
@test y == y2
@test z == z2
@test s == s2
@test t == t2


fname = joinpath(dirname(@__FILE__), "..", "data", "test-3d.dat")
x, y, z, s, t = read_dat(fname)

@test size(x) == (30,)
@test size(y) == (36,)
@test size(z) == (28,)
@test size(s) == (30,36,28,1)
@test size(t) == (1,)

@test maximum(x) == 72.5
@test maximum(y) == 71.220001
@test maximum(z) == 76.809998
@test maximum(s) == 33.2692985535
@test maximum(t) == 0

@test minimum(x) == -72.5
@test minimum(y) == -103.779999
@test minimum(z) == -58.189999
@test minimum(s) == -7.5189352036
@test minimum(t) == 0

