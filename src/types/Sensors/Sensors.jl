"""

Abstract type for storing neuroimaging sensors.

Other types inherit from the Sensor type.
And common functions can be run on all sensors sub types.

```julia
my_sensor = # Create a electrode, optode etc
label(my_sensor)  # Returns the sensor name
x(my_sensor)      # Returns the x coordinate of the sensor
```
    
"""
abstract type Sensor end


"""
Electrode sensor type used in EEG measurements.

Each electrode has a label, coordinate position, and info dictionary.

Note: the dictionary field will be depreciated and the fields will
be moved to the base type in the future. This will be invisible to the
end user, as all interaction with types should be made using functions
and not by addressing the fields themselves.
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

Each source optode has a label, coordinate position.
"""
mutable struct Source <: Optode
    label::AbstractString
    coordinate::Coordinate
    info::Dict
end

"""

Detector optode sensor type used in fNIRS measurements.

Each detector optode has a label, coordinate position.
"""
mutable struct Detector <: Optode
    label::AbstractString
    coordinate::Coordinate
end


import Base.show
function show(s::S) where {S<:Sensor}
    println(
        "Sensor: $(s.label) $(typeof(s)) - ($(s.coordinate.x), $(s.coordinate.y), $(s.coordinate.z)) ($(typeof(s.coordinate)))",
    )
end

function show(s::Array{S}) where {S<:Sensor}
    println("$(length(s)) sensors: $(typeof(s[1])) ($(typeof(s[1].coordinate)))")
end


label(s::S) where {S<:Sensor} = s.label
label(s::Array{S,1}) where {S<:Sensor} = AbstractString[si.label for si in s]
labels(s::S) where {S<:Sensor} = label(s)
labels(s::Array{S}) where {S<:Sensor} = label(s)

x(s::S) where {S<:Sensor} = s.coordinate.x
y(s::S) where {S<:Sensor} = s.coordinate.y
z(s::S) where {S<:Sensor} = s.coordinate.z
x(s::Array{S}) where {S<:Sensor} = AbstractFloat[si.coordinate.x for si in s]
y(s::Array{S}) where {S<:Sensor} = AbstractFloat[si.coordinate.y for si in s]
z(s::Array{S}) where {S<:Sensor} = AbstractFloat[si.coordinate.z for si in s]


