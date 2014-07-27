using EEG
using Logging
using Base.Test

Logging.configure(level=DEBUG)


#
# Test avr files
#

fname = joinpath(dirname(@__FILE__), "data", "test.avr")
sname = joinpath(dirname(@__FILE__), "data", "same.avr")

a, b = read_avr(fname)

write_avr(sname, a, b, 8192)

a2, b2 = read_avr(sname)

@test a==a2
@test b==b2


#
# Test dat files
#

fname = joinpath(dirname(@__FILE__), "data", "test.dat")
sname = joinpath(dirname(@__FILE__), "data", "same.dat")

x, y, z, s, t = read_dat(fname)

write_dat(sname, x, y, z, s[:,:,:,:], t)

x2, y2, z2, s2, t2 = read_dat(sname)

@test x==x2
@test y==y2
@test z==z2
@test s==s2
@test t==t2


println()
println("!! Read/Write test passed !!")
println()
