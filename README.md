## This project is currently being revitalised. We appreciate your patience or support in this process. See https://github.com/rob-luke/EEG.jl/projects/1


# EEG

Process EEG files in [Julia](http://julialang.org/).  
**For research only. Not for clinical use. Use at your own risk**.





## Status

| Release                                                                                  | Documentation                  | Testing                        |
|------------------------------------------------------------------------------------------|--------------------------------|--------------------------------|
| Julia 1.X --- **No release yet**                                                         |  **In progress**               |    [![Tests Julia 1](https://github.com/rob-luke/EEG.jl/actions/workflows/runtests.yml/badge.svg)](https://github.com/rob-luke/EEG.jl/actions/workflows/runtests.yml)    |                                                                                                                                                                                                                                                            |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Julia 0.7 --- **Release exists**                                                         |  **In progress**               |    [![Tests Julia 0.7](https://github.com/rob-luke/EEG.jl/actions/workflows/runtests_07.yml/badge.svg)](https://github.com/rob-luke/EEG.jl/actions/workflows/runtests_07.yml)   | 




## Installation

To install this package, run the following command(s) from the Julia command line:


```julia
Pkg.add("EEG")

# For the latest developements
Pkg.checkout("EEG")
```

## Documentation

Documentation can be found [here](http://codles.github.io/EEG.jl/latest/).


## Example


### Plot single and multi channel data

```julia
using EEG

s = read_SSR("file.bdf")
s = highpass_filter(s)
s = rereference(s, "Cz")
s = trim_channel(s, 8192*80, start = 8192*50)

plot_timeseries(s, channels="P6")
plot_timeseries(s)
```

![Single Channel](https://cloud.githubusercontent.com/assets/748691/17362166/210e53f4-5974-11e6-8df0-c2723c65ba52.png)
![Multi Channel](https://cloud.githubusercontent.com/assets/748691/17362167/210f9c28-5974-11e6-8a05-62fa399d32d1.png)


### Plot estimated neural activity

If you have source activity saved in a *.dat file (eg BESA) you can plot the estimated activity and local peaks of activity.

```julia
using EEG

t = read_VolumeImage("example.dat")

p = EEG.plot(t, c=:darkrainbow)
p = EEG.plot(t, find_dipoles(t), l = "Peak Activity", c=:black)

```

![Source](https://cloud.githubusercontent.com/assets/748691/17363374/523373a0-597a-11e6-94d9-826381617756.png)
