fname = joinpath(dirname(@__FILE__), "..", "data", "test-4d.dat")
sname = joinpath(dirname(@__FILE__), "..", "data", "tmp", "same.dat")

x, y, z, s, t = read_dat(fname)

@fact size(x) --> (30,)
@fact size(y) --> (36,)
@fact size(z) --> (28,)
@fact size(s) --> (30,36,28,2)
@fact size(t) --> (2,)

@fact maximum(x) --> 72.5
@fact maximum(y) --> 71.220001
@fact maximum(z) --> 76.809998
@fact maximum(s) --> 0.067409396
@fact maximum(t) --> 0.24

@fact minimum(x) --> -72.5
@fact minimum(y) --> -103.779999
@fact minimum(z) --> -58.189999
@fact minimum(s) --> 0.0
@fact minimum(t) --> 0.12

write_dat(sname, x, y, z, s[:,:,:,:], t)

x2, y2, z2, s2, t2 = read_dat(sname)

@fact x --> x2
@fact y --> y2
@fact z --> z2
@fact s --> s2
@fact t --> t2


fname = joinpath(dirname(@__FILE__), "..", "data", "test-3d.dat")
x, y, z, s, t = read_dat(fname)

@fact size(x) --> (30,)
@fact size(y) --> (36,)
@fact size(z) --> (28,)
@fact size(s) --> (30,36,28,1)
@fact size(t) --> (1,)

@fact maximum(x) --> 72.5
@fact maximum(y) --> 71.220001
@fact maximum(z) --> 76.809998
@fact maximum(s) --> 33.2692985535
@fact maximum(t) --> 0

@fact minimum(x) --> -72.5
@fact minimum(y) --> -103.779999
@fact minimum(z) --> -58.189999
@fact minimum(s) --> -7.5189352036
@fact minimum(t) --> 0

