using EEG
using BDF
using Logging
using Base.Test

Logging.configure(level=DEBUG)


#
# BIOSEMI
#

fname = joinpath(dirname(@__FILE__), "data", "test_Hz19.5-testing.bdf")

dats, evtTab, trigs, statusChan = readBDF(fname);
sampRate = readBDFHeader(fname)["sampRate"][1]

@test trigs == biosemi_trigger2channel(evtTab, dats, sampRate, code="code", index="idx", duration="dur")

@test trigs !== trigger_channel(read_ASSR(fname))

@test trigs == trigger_channel(read_ASSR(fname, valid_indices=[-1000:10000]))

s  = read_ASSR(fname)
write_ASSR(s, "testwrite.bdf")
s  = read_ASSR(fname, valid_indices=[-1000:10000])
write_ASSR(s, "testwrite.bdf")
s2 = read_ASSR("testwrite.bdf", valid_indices=[-1000:10000])

show(s)
show(s2)

@test s.data == s2.data
@test s.triggers == s2.triggers
@test s.sample_rate == s2.sample_rate


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
