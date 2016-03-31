fname = joinpath(dirname(@__FILE__), "..", "..", "data", "test.sfp")

s = read_sfp(fname)

#
# Test show
#

show(s)
show(s[1])
