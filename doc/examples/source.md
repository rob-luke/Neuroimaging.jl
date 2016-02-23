## Plot estimated neural activity

If you have source activity saved in a *.dat file (eg BESA) you can plot the estimated activity and local peaks of activity.

```julia
using EEG

t = read_VolumeImage("example.dat")

p = EEG.plot(t)
p = EEG.plot(t, find_dipoles(t), l = "Peak Activity", c=:blue)

```

![PNG](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/sources.png)
