using EEG
using Logging
using Gadfly

Logging.configure(level=DEBUG)

#
# Plot dat file
#

using Winston

fname = joinpath(dirname(@__FILE__), "../data", "test-3d.dat")

x, y, z, s, t = read_dat(fname)

s = squeeze(mean(s, 4), 4)

f = plot_dat(x, y, z, s, ncols=2, threshold=0, max_size=1)

Winston.savefig(f, joinpath(dirname(@__FILE__), "../data/tmp", "dat-file1.pdf"),
    height = int(round(1.1*600)), width=int(round(1.1*600)))
Winston.savefig(f, joinpath(dirname(@__FILE__), "../data/tmp", "dat-file1.png"),
    height = int(round(1.1*600)), width=int(round(1.1*600)))

f = plot_dat(x, y, z, s, ncols=4, threshold=0, max_size=1)

Winston.savefig(f, joinpath(dirname(@__FILE__), "../data/tmp", "dat-file2.pdf"),
    height = int(round(1.1*600)), width=int(round(1.1*4*600)))

#
# Read in BDF data
#

fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)

s = trim_channel(s, 8192*3)





