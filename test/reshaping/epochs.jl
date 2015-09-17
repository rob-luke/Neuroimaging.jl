#######################################
#
# Test epochs extracted and converted to sweeps
#
#######################################

# Input
fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")
s = read_SSR(fname)

s = extract_epochs(s)
@test size(s.processing["epochs"]) == (8388,28,6)

s = create_sweeps(s; epochsPerSweep=4)
@test size(s.processing["sweeps"]) == (33552,7,6)

julia_result = average_epochs(s.processing["sweeps"])

# MATLAB
filen = matopen(joinpath(dirname(@__FILE__), "../data", "sweeps.mat"))
matlab_sweeps = read(filen, "sweep")
close(filen)

@test_approx_eq_eps matlab_sweeps[:,1:6] julia_result 0.0001

println()
println("!! Epoch test passed !!")
println()
