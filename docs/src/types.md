# Data Types

A feature of the Julia programming language is the strong type system.
This package exploits that strength and defines various types for storing
information about your neuroimaging data. A general hierarchy of neuroimaging types is provided.

A number of types are provided to handle different types of data.
Functions are provided to perform common operations on each type.
For example, the function `channelnames` would return the correct
information when called on a general eeg recording or steady state response data type.
Users should interact with types using function, and not address the underlying
fields directly. This allows the underlying data type to be improved without breaking
existing code. For example, do not address `sensor.label`, you should use `label(sensor)`.

Types also exist for storing metadata. For example, `electrodes`
are a sub type of the `Sensor` type. And the position
of the sensors may be in the `Talairach` space, which is a subtype of
the `Coordinate` type.
This type hierarchy may be more than two levels deep. For example,
the `source` type inherits from the `optode` type which inherits from the `sensor` type.
All functions that operate on the top level type will also operate on lower level types,
but not all functions that operate on low level types would operate on the top level.
For example, the `SSR` type supports the function `modulationrate()` but the `EEG` type does not,
as not all EEG measurements were obtained with a modulated stimulus.

A brief description of each type is provided below.
See the following documentation sections for more details of each type,
including examples and function APIs.


## Supported Data Types

```@meta
CurrentModule = Neuroimaging
```

```@docs
Neuroimaging
```


### Measurement

This package provides for different neuroimaging techniques such as EEG and fNIRS.
All of these types inherit from the top level abstract `NeuroimagingMeasurement` type.

```@docs
NeuroimagingMeasurement
```

Within the `NeuroimagingMeasurement` type a sub type is provided for each supported imaging modality (e.g., `EEG`).
Within each imaging modality, types are provided to represent the experimental paradigm used to collect the data (e.g., `SSR` or `RestingStateEEG`).
Additionally a `General` type is provided for data that is collected using a paradigm not yet supported in _Neuroimaging.jl_ (e.g., `GeneralEEG`).
This hierarchical structure allows for specific features to be added to  analysis procedures for specific experimental designs,
while inheriting generic features and function from the parent types.
For example, see the [Auditory Steady State Response Example](@ref) which uses the `SSR` type which is a sub type of `EEG`.
In this example, we see that any EEG function to be run on `SSR` data, such as filtering or resampling,
but also allows for application specific functions such as specific frequency analysis statistical tests.

!!! note "Support for more types is welcomed"

    If you would like to add support for a different experimental paradigm by adding a sub type
    then please raise an issue on the GitHub page and we can work through it together.
    Some additional types that would be good to support are `RestingStateEEG`, `P300`, etc.

```@docs
EEG
GeneralEEG
SSR
TR
```


### Sensor

Support is provided for the storing of sensor information via the `Sensor` type.
As with the neuroimaging type, several sub types inherit from this top level type.

```@docs
Sensor
```

Support is currently provided for EEG and fNIRS sensor types.
Additional types are welcomed.

```@docs
Electrode
Optode
Source
Detector
```


### Coordinate

Support is provided for the storing of coordinate information via the `Coordinate` type.

```@docs
Coordinate
```

Specific coordinate systems available are.

```@docs
BrainVision 
Talairach
SPM
UnknownCoordinate
```


### Other

These types need to be better documented.

```@docs
VolumeImage
Dipole
```
