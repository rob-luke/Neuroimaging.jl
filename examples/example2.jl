using EEGjl

using Winston

x, y, z, s, t = read_dat("../data/Example-40Hz.dat")

m = squeeze(mean(s,4),4)

p = plot_dat(x, y, z, m)

file(p, "Eg2-Sources.png", width=800, height=800)

t = read_bsa("../data/Example-40Hz.bsa", verbose=true)

p = oplot_dipoles(p, t)

file(p, "Eg2-Sources-w-dipoles.png", width=800, height=800)


