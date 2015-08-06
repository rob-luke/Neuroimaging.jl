
fname = joinpath(dirname(@__FILE__), "../../data", "test-4d.dat")

t = read_VolumeImage(fname)

show(t)

#
# Test basic functions
#

s = t + t
s = t - t
s = t / t
s = t / 3
s = mean(t)


#
# Test error is thrown for mismatched units
#

t2 = read_VolumeImage(fname)
t2.units = "A/m^3"

#= @test_throws ErrorException t + t2 =#


#
# Test error is thrown for mismatched dimensions
#

t2 = read_VolumeImage(fname)
t2 = mean(t2)

#= @test_throws ErrorException t + t2 =#




println()
println("!! Volume image test passed !!")
println()
