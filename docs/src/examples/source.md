# Source

If you have source activity saved in a *.dat file (eg BESA) you can plot the estimated activity and local peaks of activity.

```julia
using EEG

t = read_VolumeImage("example.dat")

p = EEG.plot(t, c=:darkrainbow)
p = EEG.plot(t, find_dipoles(t), l = "Peak Activity", c=:black)

```

![PNG](https://cloud.githubusercontent.com/assets/748691/17363374/523373a0-597a-11e6-94d9-826381617756.png)
