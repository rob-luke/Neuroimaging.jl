# Coordinate Systems

There are a wide variety of coordinate systems used in Neuroimaging.
`Neuroimaging.jl` provides a coordinate data type, and several
subtypes associated with specific systems. Conversion between coordinate
systems is available.
For a general overview of coordinate systems in neuroimaging see:

* https://mne.tools/dev/auto_tutorials/forward/20_source_alignment.html
* https://www.fieldtriptoolbox.org/faq/coordsys/

This package currently supports `SPM`, `BrainVision`, and `Talairach`
coordinates and conversion. Additionally, an `Unknown` coordinate system
can be used if you don't know how your locations are mapped.


## Create a coordinate

We can create a coordinate point by calling the appropriate type.
Internally `Neuroimaging.jl` uses SI units, so meters for these locations.
But the results are displayed in the more convenient centimeter notation.

By default everything is SI units, so if you pass in a distance without
specifying the unit it will be in meters.

```@example fileread
using DisplayAs # hide
using Neuroimaging, Unitful

SPM(0.0737, -0.0260, 0.0070)
```

However, it is clearer and less prone to error if you specify the unit
at construction, and let the internals handle the conversion.

```@example fileread
location_1 = SPM(73.7u"mm", -26u"mm", 7u"mm")
```
Note that this position is taken from table IV from:

* Lancaster, Jack L., et al. "Bias between MNI and Talairach coordinates analyzed using the ICBM‐152 brain template." Human brain mapping 28.11 (2007): 1194-1205.


## Conversion between coordinates

To convert between different coordinate systems simply call the `convert` function
with the first arguments as the desired coordinate system. The `show` function
displays the passed type nicely with domain appropriate units.

```@example fileread
show(convert(Talairach, location_1))
```

And we can see that the resulting value is similar to what is provided in the Lancaster 2007 article.
Although not exact, there is some loss in the transformations.


## Sensors

Sensors contain location information stored as coordinate types.
So if we load an EEG measurement...

```@example fileread
using Neuroimaging, DataDeps
data_path = joinpath(
    datadep"ExampleSSR",
    "Neuroimaging.jl-example-data-master",
    "neuroimaingSSR.bdf",
)

s = read_SSR(data_path)
```

we can then query the sensors by calling...

```@example fileread
sensors(s)
```

And we can see that there are 7 electrodes with standard 10-20 names.
However, they do not have positions encoded by default.

!!! note "Great first issue"

    A mapping for standard position names like 10-20 or 10-05 to coordinates
    would be a great improvement to the project.

We can query the coordinate positions for the electrodes. For example,
to obtain the x locations for all sensors in the EEG measurement use...

```@example fileread
x(sensors(s))
```

or to get all the labels use...

```@example fileread
labels(sensors(s))
```
