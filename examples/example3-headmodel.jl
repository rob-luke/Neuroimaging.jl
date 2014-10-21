using Leadfield         # Private repo
using EEG
using TextPlots

println()
println()

#
# Read EEG and determine scalp sensor statistics
#

s = read_SSR("/Users/rluke/Documents/Data/EEG/BDFs/NH/Example-40Hz.bdf", verbose=true)

s = highpass_filter(s, cutOff=2, verbose=true)

s = rereference(s, "average", verbose=true)

s = extract_epochs(s, verbose=true)

s = create_sweeps(s, epochsPerSweep=16, verbose=true)

s = ftest(s, 40.0391, verbose=true, side_freq=2)

edges, counts = hist(s.processing["ftest1"][:SNRdB])
plot([edges[1:end-1]], counts)

println()
println("ftest SNR (dB) mean and sd and max:")
println(mean(s.processing["ftest1"][:SNRdB]))
println(std(s.processing["ftest1"][:SNRdB]))
println(maximum(s.processing["ftest1"][:SNRdB]))
println()


#
# Read source analysis and find dipole
#

x, y, z, d, t = read_dat("/Users/rluke/Documents/Data/EEG/BDFs/NH/Example-40Hz.dat", verbose=true)

d = convert(Array{FloatingPoint}, squeeze(maximum(d, 4), 4))

dips = find_dipoles(d, x=x, y=y, z=z, t=t, verbose=true)

left_true  = Talairach(-45.4325, -15.105,   6.8045)
right_true = Talairach( 48.2795, -21.53475, 1.80525)

best_left  = best_dipole(left_true,  dips)
best_right = best_dipole(right_true, dips)


#
# Read leadfield and project down
#

L = import_leadfield()

L = match_leadfield(L, s)
println()

idx_Left  = find_location(L, best_left,  verbose=true)
idx_Right = find_location(L, best_right, verbose=true)
println()

source_left  = project(s, L, idx_Left,  verbose=true)
source_right = project(s, L, idx_Right, verbose=true)
println()

s = add_channel(s, source_left[1,:]', "Left_x", verbose=true)
s = add_channel(s, source_left[2,:]', "Left_y", verbose=true)
s = add_channel(s, source_left[3,:]', "Left_z", verbose=true)
println()

s = add_channel(s, source_right[1,:]', "Right_x", verbose=true)
s = add_channel(s, source_right[2,:]', "Right_y", verbose=true)
s = add_channel(s, source_right[3,:]', "Right_z", verbose=true)
println()


#
# Stats on projection
#

remove_channel!(s, 1:64, verbose=true)

s = extract_epochs(s, verbose=true)

s = create_sweeps(s, epochsPerSweep=16, verbose=true)

s = ftest(s, 40.0391, verbose=true, side_freq=2)

println(s.processing["ftest2"])
println(s.processing["ftest2"][:SNRdB])
