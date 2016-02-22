# EEG

Process EEG files in [Julia](http://julialang.org/).  
**For research only. Not for clinical use. Use at your own risk**

##### Release: [![EEG](http://pkg.julialang.org/badges/EEG_0.4.svg)](http://pkg.julialang.org/?pkg=EEG)

##### Development: [![Build Status](https://travis-ci.org/codles/EEG.jl.svg?branch=master)](https://travis-ci.org/codles/EEG.jl) [![Build status](https://ci.appveyor.com/api/projects/status/3r96gn3o7owl5psh/branch/master?svg=true)](https://ci.appveyor.com/project/codles/eeg-jl-91eci/branch/master) [![Coverage Status](https://img.shields.io/coveralls/codles/EEG.jl.svg)](https://coveralls.io/r/codles/EEG.jl?branch=master)

##### Info: [![Join the chat at https://gitter.im/codles/EEG.jl](https://badges.gitter.im/codles/EEG.jl.svg)](https://gitter.im/codles/EEG.jl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Documentation Status](https://readthedocs.org/projects/eegjl/badge/?version=latest)](https://eegjl.readthedocs.org/en/latest/)


## Installation

To install this package, run the following command into Julia's command line:


```julia
Pkg.add("EEG")

# For the latest developements
Pkg.checkout("EEG")
```

## Documentation

See [documentation](https://eegjl.readthedocs.org/) or [old api documentation](http://codles.github.io/EEG.jl/) (in transition).  



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



### Plot F-test spectrum

```julia
using EEG, Gadfly

a = read_SSR("file.bdf")

# Preprocess data
a = highpass_filter(a)
a = rereference(a, "Cz")
a = merge_channels(a, EEG_Vanvooren_2014, "Merged")
    remove_channel!(a, EEG_64_10_20)
a = extract_epochs(a)
a = create_sweeps(a)

# Plot and save ftest spectrum
f = plot_ftest(a)
    draw(PNG("ftest.png", 16inch, 8inch), f)
```

![Ftest](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/ftest.png)


### Plot statistics at each frequency, highlighting the first 4 harmonics


```julia

using EEG, DataFrames, Gadfly


# Read file and pre processing
a = read_SSR("Example-40Hz.bdf")
a = highpass_filter(a)
a = rereference(a, "Cz")
a = merge_channels(a, EEG_Vanvooren_2014, "Merged")
    remove_channel!(a, EEG_64_10_20)


# Run an F-test and save data
a = extract_epochs(a)
a = create_sweeps(a)
a = ftest(a, modulationrate(a)*[1, 2, 3, 4]) # Look at harmonics
a = ftest(a, [2:200])                        # Look at off stimulation frequencies
a = save_results(a)


# Read the saved data and plot with Gadfly.jl
df = readtable("Example-40Hz.csv")
df[:Significant] = df[:Statistic] .< 0.05

p = plot(df, x="AnalysisFrequency", y="SNRdB", color="Significant",
             xintercept=float(a.modulation_frequency)*[1, 2, 3, 4],
             Geom.vline(color="black"), Geom.point,
             Guide.title("40Hz SSR Highlighting First 4 Harmonics"),
             Guide.xlabel("Frequency (Hz)"), Guide.ylabel("SNR (dB)"),
             Scale.discrete_color_manual("red","green"))

draw(PNG("Example-40Hz.png", 18cm, 12cm), p)
```


Results in the following figure which displays the SNR at each frequency.
The vertical lines highlight the harmonics of the stimulus and color represents if a significant response was detected.

![SSR Example](doc/images/Example-40Hz-SSR.png)

### Plot estimated neural activity

If you have source activity saved in a *.dat file (eg BESA) you can plot the estimated activity and local peaks of activity.

```julia
using EEG

t = read_VolumeImage("example.dat")

p = EEG.plot(t)
p = EEG.plot(t, find_dipoles(t), l = "Peak Activity", c=:blue)

```

![PNG](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/sources.png)
