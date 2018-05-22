# EEG

Process EEG files in [Julia](http://julialang.org/).  
**For research only. Not for clinical use. Use at your own risk**.



## Status

| Release                                                                                  | Documentation                                                                                                                                                                                                                                                                                                 | Development                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
|------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [![EEG](http://pkg.julialang.org/badges/EEG_0.4.svg)](http://pkg.julialang.org/?pkg=EEG) |                                                                                                                                                                                                                                                                                                               |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| [![EEG](http://pkg.julialang.org/badges/EEG_0.5.svg)](http://pkg.julialang.org/?pkg=EEG) | [![](https://img.shields.io/badge/docs-latest-blue.svg)](https://codles.github.io/EEG.jl/latest),[![Join the chat at https://gitter.im/codles/EEG.jl](https://badges.gitter.im/codles/EEG.jl.svg)](https://gitter.im/codles/EEG.jl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) | [![Build Status](https://travis-ci.org/rob-luke/EEG.jl.svg?branch=master)](https://travis-ci.org/rob-luke/EEG.jl) [![Build status](https://ci.appveyor.com/api/projects/status/3r96gn3o7owl5psh/branch/master?svg=true)](https://ci.appveyor.com/project/codles/eeg-jl-91eci/branch/master) [![Coverage Status](https://coveralls.io/repos/github/codles/EEG.jl/badge.svg?branch=master)](https://coveralls.io/github/codles/EEG.jl?branch=master) [![codecov](https://codecov.io/gh/codles/EEG.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/codles/EEG.jl) |




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
