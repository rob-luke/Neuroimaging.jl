# Accessing measurement properties

The `Neuroimaging.jl` library uses functions to access underlying
properties of the data structures. This is to enable a consistent
API to users, while allowing flexibility in the underlying design.

To minimise the risk of making errors when specifying values, passing
arguments, and scaling values, the `Neuroimaging.jl` library uses
units wherever possible. The `Unitful.jl` package provides a convenient
interface for handling unitful data.


## Handling of units

Many of the underlying components of this package store values with units.
For example, coordinates are stored internally in the unit of meters,
and sampling rates are stored in hertz. This minimises errors in two ways.
First, if you pass arguments in the wrong order to a function it may be caught.
Second, if you accidentally pass kHz as a sample rate this will be correctly
converted to Hz for you internally.


## Retrieving information from data

To access information about your neuroimaging data you must query
it using the provided functions. A list of functions is provided for each type
in the documentation. And common functions available across all types are described
in the types documentation.
So for example, if you wanted to query the samplerate of a measurement:

```@example fileread
using Neuroimaging, DataDeps, Unitful
data_path = joinpath(
    datadep"ExampleSSR",
    "Neuroimaging.jl-example-data-master",
    "neuroimaingSSR.bdf",
)
s = read_EEG(data_path)
samplingrate(s)
```

However, sometime you do not want the data with its units.
Let us say you want the sample rate in kHz.
In this case you can pipe the data manually...

```@example fileread
samplingrate(s) |> u"kHz" |> ustrip 
```

Or you may wish to know the sample rate in mHz and require
that the value is an integer, then you could run...

```@example fileread
samplingrate(s) |> u"mHz" |> ustrip |> Int
```

Or you could simply specify the return type of the function...

```@example fileread
samplingrate(Float64, s)
```

You should access all properties of the data in this fashion.
For example the functions `data`, `modulationrate`, `channel_names`
should all be used to query this properties.


## Displaying data properties

The underlying data is stored with units wherever possible
and in SI units. This makes it easy to keep track of everything
when programming. However, when we report data these units may
not be appropriate. For example, fNIRS data is usually reported in micro
Mol, it would be inconvenient to report and plot values with six leading zeros.
Similarly locations of neuroimaging coordinates are often reported in millimeters.
So the `show` functions will report the data in the typical scale for the
area of research.


```@example fileread
show(sensors(s)[2])
```