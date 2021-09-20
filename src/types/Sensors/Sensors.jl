"""
Abstract type for storing neuroimaging sensors.

Other types inherit from the Sensor type.
And common functions can be run on all sensors sub types.
All sensors have a label and coordinate.
Some sensors also store additional information.
For example, fNIRS sensors may hold wavelength information.

All Sensor types support the following functions:

* `label()`
* `labels()`
* `x()`
* `y()`
* `z()`

```julia
my_sensor = # Create a electrode, optode etc
label(my_sensor)  # Returns the sensor name
x(my_sensor)      # Returns the x coordinate of the sensor
```
"""
abstract type Sensor end


"""
Electrode sensor type used in EEG measurements.
"""
mutable struct Electrode <: Sensor
    label::AbstractString
    coordinate::Coordinate
    info::Dict
end


"""
Optode abstract sensor type used in fNIRS measrurements.
"""
abstract type Optode <: Sensor end


"""
Source optode sensor type used in fNIRS measurements.
"""
mutable struct Source <: Optode
    label::AbstractString
    coordinate::Coordinate
    info::Dict
end


"""
Detector optode sensor type used in fNIRS measurements.
"""
mutable struct Detector <: Optode
    label::AbstractString
    coordinate::Coordinate
    info::Dict
end


import Base.show
function show(s::S) where {S<:Sensor}
    println(
        "Sensor: $(s.label) $(typeof(s)) - ($(s.coordinate.x |> u"mm"), $(s.coordinate.y |> u"mm"), $(s.coordinate.z |> u"mm")) ($(typeof(s.coordinate)))",
    )
end

function show(s::Array{S}) where {S<:Sensor}
    println("$(length(s)) sensors: $(typeof(s[1])) ($(typeof(s[1].coordinate)))")
end


label(s::S) where {S<:Sensor} = s.label
label(s::Array{S,1}) where {S<:Sensor} = [si.label for si in s]
labels(s::S) where {S<:Sensor} = label(s)
labels(s::Array{S}) where {S<:Sensor} = label(s)

x(s::S) where {S<:Sensor} = s.coordinate.x
y(s::S) where {S<:Sensor} = s.coordinate.y
z(s::S) where {S<:Sensor} = s.coordinate.z
x(s::Array{S}) where {S<:Sensor} = [si.coordinate.x for si in s]
y(s::Array{S}) where {S<:Sensor} = [si.coordinate.y for si in s]
z(s::Array{S}) where {S<:Sensor} = [si.coordinate.z for si in s]


