using EEGjl

using Winston

x, y, z, s, t = read_dat("../data/Example_40Hz_SWN_70dB_R.dat")

m = squeeze(mean(s,4),4)

p = plot_dat(x, y, z, m)

file(p, "Eg3-Sources.png", width=800, height=800)

