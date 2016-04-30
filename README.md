# EEG

Process EEG files in [Julia](http://julialang.org/).  
**For research only. Not for clinical use. Use at your own risk**

##### Release: [![EEG](http://pkg.julialang.org/badges/EEG_0.4.svg)](http://pkg.julialang.org/?pkg=EEG)

##### Development: [![Build Status](https://travis-ci.org/codles/EEG.jl.svg?branch=master)](https://travis-ci.org/codles/EEG.jl) [![Build status](https://ci.appveyor.com/api/projects/status/3r96gn3o7owl5psh/branch/master?svg=true)](https://ci.appveyor.com/project/codles/eeg-jl-91eci/branch/master) [![Coverage Status](https://coveralls.io/repos/github/codles/EEG.jl/badge.svg?branch=master)](https://coveralls.io/github/codles/EEG.jl?branch=master) [![codecov](https://codecov.io/gh/codles/EEG.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/codles/EEG.jl)



##### Info: [![Join the chat at https://gitter.im/codles/EEG.jl](https://badges.gitter.im/codles/EEG.jl.svg)](https://gitter.im/codles/EEG.jl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Documentation Status](https://readthedocs.org/projects/eegjl/badge/?version=latest)](https://eegjl.readthedocs.org/en/latest/)


## Installation

To install this package, run the following command into Julia's command line:


```julia
Pkg.add("EEG")

# For the latest developements
Pkg.checkout("EEG")
```

## Documentation

See [documentation](https://eegjl.readthedocs.org/).



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

![Single Channel](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/singlechannel-timeseries.png)
![Multi Channel](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/multichannel-timeseries.png)


### Plot estimated neural activity

If you have source activity saved in a *.dat file (eg BESA) you can plot the estimated activity and local peaks of activity.

```julia
using EEG

t = read_VolumeImage("example.dat")

p = EEG.plot(t)
p = EEG.plot(t, find_dipoles(t), l = "Peak Activity", c=:blue)

```

![PNG](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/sources.png)
