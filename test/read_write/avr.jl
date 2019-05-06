fname = joinpath(dirname(@__FILE__), "..", "data", "test.avr")
sname = joinpath(dirname(@__FILE__), "..", "data", "tmp", "same.avr")

a, b = read_avr(fname)

write_avr(sname, a, b, 8192)

a2, b2 = read_avr(sname)

@test a == a2
@test b == b2

