using EEG
using Logging
using Gadfly

Logging.configure(level=DEBUG)

#
# Read in data
#

fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")

s = read_SSR(fname)

#
# Multi channel time series
#

plot1 = plot_timeseries(s)
draw(PDF(joinpath(dirname(@__FILE__), "../data/tmp", "timeseries-plot-1.pdf"), 4inch, 3inch), plot1)

plot2 = plot_timeseries(s, channels=["40Hz_SWN_70dB_R", "Cz"])
draw(PDF(joinpath(dirname(@__FILE__), "../data/tmp", "timeseries-plot-2.pdf"), 8inch, 4inch), plot2)


s = rereference(s, "Cz")
plot3 = plot_timeseries(s, channels=["40Hz_SWN_70dB_R", "Cz"])
draw(PDF(joinpath(dirname(@__FILE__), "../data/tmp", "timeseries-plot-3.pdf"), 10inch, 6inch), plot3)


#
# Single channel time series
#

plot4 = plot_timeseries(s, channels=["40Hz_SWN_70dB_R"])
draw(PDF(joinpath(dirname(@__FILE__), "../data/tmp", "timeseries-plot-4.pdf"), 10inch, 6inch), plot4)

plot5 = plot_timeseries(s, channels="Cz")
draw(PDF(joinpath(dirname(@__FILE__), "../data/tmp", "timeseries-plot-5.pdf"), 10inch, 6inch), plot5)

keep_channel!(s, ["40Hz_SWN_70dB_R"])

plot6 = plot_timeseries(s)
draw(PDF(joinpath(dirname(@__FILE__), "../data/tmp", "timeseries-plot-6.pdf"), 10inch, 6inch), plot6)
