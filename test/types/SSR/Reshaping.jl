fname = joinpath(dirname(@__FILE__), "../../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)


#
# extract_epochs
# --------------
#

s = extract_epochs(s)

@test size(s.processing["epochs"]) == (8388,28,6)

s = extract_epochs(s, valid_triggers=[1, 2])

@test size(s.processing["epochs"]) == (8388,28,6)

s = extract_epochs(s, valid_triggers = [1])

@test size(s.processing["epochs"]) == (16776,14,6)

s = extract_epochs(s, valid_triggers = 1)

@test size(s.processing["epochs"]) == (16776,14,6)

@test_throws ErrorException extract_epochs(s, valid_triggers = -4)


#
# epoch_rejection
# ---------------
#

s = extract_epochs(s)

s = epoch_rejection(s)

@test floor(28 * 0.95) == size(s.processing["epochs"], 2)

for r in 0.1 : 0.1 : 1

    s = extract_epochs(s)

    s = epoch_rejection(s, retain_percentage = r)

    @test floor(28 * r) == size(s.processing["epochs"], 2)

end


#
# create_sweeps
# -------------
#

s = extract_epochs(s)

@test_throws ErrorException create_sweeps(s)

for l in 4 : 4 : 24

    s = extract_epochs(s)

    s = create_sweeps(s, epochsPerSweep = l)

    @test size(s.processing["sweeps"], 2) == floor(28 / l)
    @test size(s.processing["sweeps"], 1) == l * size(s.processing["epochs"], 1)
    @test size(s.processing["sweeps"], 3) == size(s.processing["epochs"], 3)
end
