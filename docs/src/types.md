# Types

A feature of the Julia programming language is the strong type system.
This package exploits that strength and defines various types for storing
information about your neuroimaging data.

A number of types are provided to handle different types of data.
Functions are provided to perform common operations on each type.
For example, the function channelnames would return the correct
information when called on a steady state response or evoked potential
data type (yet to be implemented).

Types also exist for storing metadata. For example, electrode sensor
positions are a sub type of the `Sensor` type. And the position
of the sensors may be in the `Talairach` space, which is a subtype of
the `Coordinate` type.

A brief description of each type is provided below.
See the following documentation sections for more details of each type,
including examples and function APIs.

## Available types

```@meta
CurrentModule = EEG
```

### Measurement

```@docs
SSR
```

### Sensor

```@docs
Sensor
Electrode
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


## To be implemented

* Generic electromagnetic type.
* Generic EEG type. Then make SSR inherit from this.
* Generic MEG type.
* Add evoked response type
* Add optodes
* Add MEG sensors
