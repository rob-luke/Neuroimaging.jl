# Types

A feature of the Julia programming language is the strong type system.
This package exploits that strength and defines various types for storing
information about your neuroimaging data.

A number of types are provided to handle different types of data.
Functions are provided to perform common operations on each type.
For example, the function `channelnames` would return the correct
information when called on a general eeg recording or steady state responsedata type.
Users should interact with types using function, and not address the underlying
fields directly. This allows the underlying data type to be improved without breaking
existing code. For example, do not address `sensor.label`, you should use `label(sensor)`.

Types also exist for storing metadata. For example, electrodes
are a sub type of the `Sensor` type. And the position
of the sensors may be in the `Talairach` space, which is a subtype of
the `Coordinate` type.

A brief description of each type is provided below.
See the following documentation sections for more details of each type,
including examples and function APIs.


## Available types

```@meta
CurrentModule = Neuroimaging
```

### Measurement

This package provides for different neuroimaging techniques such as EEG and fNIRS,
and these are represented as top level abstract types.

Within these types support is provided for different types of neuroimaging paradigms
which are sub types of the top level techniques.
For example, if you have acquired data of a steady state response using the EEG methodology you would use the SSR type.
A general type is also provided for each imaging technique.
For example, if your EEG study design does not fit one of the neuroimaging paradigms implemented in this package you can
use the `GeneralEEG` type.

```@docs
EEG
GeneralEEG
SSR
```


### Sensor

```@docs
Sensor
Electrode
Optode
Source
Detector
```


### Coordinate

```@docs
Coordinate
BrainVision 
Talairach
SPM
UnknownCoordinate
```


### Other

```@docs
VolumeImage
Dipole
```
