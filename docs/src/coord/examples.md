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

!!! note "Refactoring in progress"

    This example demonstrates the existing capabilities of the package.
    General improvements are planned to this package. But before changes are made,
    the existing features and functions will be documented. This will help to highlight
    was has already been implemented, and where improvements need to be made.
    For a rough plan of how the package is being redeveloped see the GitHub issues and
    [project board](https://github.com/rob-luke/Neuroimaging.jl/projects/1).


## Create a coordinate

We can create a coordinate point by calling the appropriate type.
Internally `Neuroimaging.jl` uses SI units, so meters for these locations.
But the results are displayed in the more convenient centimeter notation.

```@example fileread
using DisplayAs # hide
using Neuroimaging

location_1 = SPM(0.737, -0.260, 0.070)
```

Note that this position is taken from table IV from:

* Lancaster, Jack L., et al. "Bias between MNI and Talairach coordinates analyzed using the ICBM‐152 brain template." Human brain mapping 28.11 (2007): 1194-1205.


## Conversion between coordinates

To convert between different coordinate systems simply call the ``convert`` function
with the first arguments as the desired coordinate system.

```@example fileread
convert(Talairach, location_1)
```

And we can see that the resulting value is similar to what is provided in the Lancaster 2007 article.
Although not exact, there is some loss in the transformations.
