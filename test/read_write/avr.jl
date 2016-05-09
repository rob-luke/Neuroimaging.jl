fname = joinpath(dirname(@__FILE__), "..", "data", "test.avr")
sname = joinpath(dirname(@__FILE__), "..", "data", "tmp", "same.avr")

a, b = read_avr(fname)

write_avr(sname, a, b, 8192)

a2, b2 = read_avr(sname)

@fact a --> a2
@fact b --> b2

