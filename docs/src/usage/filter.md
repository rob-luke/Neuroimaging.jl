# Filtering

`Neuroimaging.jl` provides a flexible filtering interface with
sane defaults for different data and experimental types,
this is achieved by providing a light wrapper over the `DSP.jl` backend.

!!! note "DSP.jl documentation"

    The filtering processes for this package are dependent on the `DSP.jl`
    package. As such, we recommend reading the 
    [DSP.jl documentation](https://docs.juliadsp.org/stable/contents/)
    to understand the design choices used in this pacakge,
    and to utilise the ability to define custom filtering.


## Import example EEG data

To demonstrate the filtering capabilities of this package we first
import some example data.
For simplicity, we will simply process one channel of data in this
example.


```@example filter
using DisplayAs # hide
using Neuroimaging, DataDeps, StatsBase, Unitful

data_path = joinpath(
    datadep"ExampleSSR",
    "Neuroimaging.jl-example-data-master",
    "neuroimaingSSR.bdf",
)

s = read_SSR(data_path)
s.data = s.data .- StatsBase.mean(s.data, dims=1) # remove DC offset for easier plotting
keep_channel!(s, "F5")
s
```


## Modality specific filter

`Neuroimaging.jl` provides standard filter functions for each data type
and experimental design type. This allows you to quickly get started with
sane filtering parameters. First we demonstrate the standard filtering functions
applied to two data types. Then, below we demonstrate how to apply a custom
defined filter to any `Neuroimaging.jl` type.


### SSR

The [steady state response](@ref ssr_intro) type uses a third order
Butterworth filter with a 2 Hz cutoff by default. The filter is applied
twice to achieve zero phase filtering, by using the `filtfilt` function
from DSP.jl.



```@example filter
using Plots

s_hp = filter_highpass(s)

plot(s, label="Original Signal")
plot!(s_hp, label="Filtered Signal")
current() |> DisplayAs.PNG # hide
```


### EEG

For general EEG types a FIR filter is utilised with a Hamming window.
By default zero phase filtering is applied by compensating for the delay of the
filter.


```@example filter
s2 = read_EEG(data_path)
s2.data = s2.data .- StatsBase.mean(s2.data, dims=1) # remove DC offset for better plotting
keep_channel!(s2, "F5")

s_hp = filter_highpass(s2, cutOff = 2u"Hz")
s_lp = filter_lowpass(s2, cutOff = 5u"Hz") # extreme value to show LP effect in plot

plot(s2, label="raw")
plot!(s_hp, label="highpass")
plot!(s_lp, label="lowpass")
current() |> DisplayAs.PNG # hide
```


## Custom defined filter

In addition to the default filtering above, `Neuroimaging.jl` provides the user
completely flexibility in filtering the data by allowing standard `DSP.jl`
objects to be used directly on data types. The functions `filt` and `filtfilt`
are both exposed to the user and work with all `Neuroimaging.jl` data types.

In this example a custom zero pole gain implementation of a 6th order 
Butterworth filter is applied to the SSR data. The filter is applied using
both the zero-phase `filtfilt` approach and the standard `filt`.


```@example filter
using DSP
responsetype =  Highpass(3, fs = samplingrate(Float64, s))
designmethod =  Butterworth(6)
zpg = digitalfilter(responsetype, designmethod)

# Apply filtering using each exposed method
s_custom_filtfilt = Neuroimaging.filtfilt(s, zpg) 
s_custom_filt = Neuroimaging.filt(s, zpg) 

s = trim_channel(s, 10000)
s_custom_filtfilt = trim_channel(s_custom_filtfilt, 10000)
s_custom_filt = trim_channel(s_custom_filt, 10000)

plot(s, label="raw")
plot!(s_custom_filtfilt, label="filtfilt")
plot!(s_custom_filt, label="filt")
current() |> DisplayAs.PNG # hide
```


## Summary

We have demonstrated how to apply standard and custom filtering to your
neuroimaging data. If your specific experimental design data has a common
filtering specification that is not yet included in `Neuroimaging.jl`, then
please raise an issue on the GitHub page and we can add support for your data
type.

