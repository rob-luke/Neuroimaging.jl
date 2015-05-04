## Single and multi channel data

```julia
using EEG, Gadfly

# Pre process data
s = read_SSR("file.bdf")
s = highpass_filter(s)
s = rereference(s, "Cz")
    keep_channel!(s, EEG_Vanvooren_2014)        # Reduce number of channels
s = trim_channel(s, 8192*80, start = 8192*50)   # Reduce length of signal to plot

# Plot multi channel time series
f = plot_timeseries(s)
    draw(PNG("multichannel-timeseries.png", 8inch, 6inch), f)

# Plot single channel time series
f = plot_timeseries(s, channels="P6")
    draw(PNG("singlechannel-timeseries.png", 8inch, 3inch), f)
```

![Multi Channel](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/multichannel-timeseries.png)
![Single Channel](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/singlechannel-timeseries.png)
