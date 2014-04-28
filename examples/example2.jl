using EEGjl

using Leadfield

using Winston

t = read_bsa("../data/Example.bsa", verbose=true)

Xcords, Ycords, Zcords = readSRF("/Users/rluke/Documents/GITs/Leadfield.jl/data/Default50Skin.srf", verbose=true)

Xcords, Ycords, Zcords = conv_bv2tal(Xcords, Ycords, Zcords, verbose=true)

p = plotSRF(Xcords, Ycords, Zcords)
file(p, "test1.png", width=800, height=800)

p = oplot_dipoles(p, t, verbose=true)
file(p, "test2.png", width=800, height=800)

