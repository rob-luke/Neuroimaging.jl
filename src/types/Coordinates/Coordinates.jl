"""
Abstract type for coordinates in three dimensions

    All sub types have x, y, z coordinates.
    And conversion is available between subtypes using the convert function.

```julia
bv_coord = (0.3, 2, 3.1)
tal_coord = convert(Talairach, mni)
```
"""
abstract type Coordinate end

"""
Type for BrainVision coordinate system.
"""
mutable struct BrainVision <: Coordinate
    x::Number
    y::Number
    z::Number
end

"""
Type for Talairach coordinate system.
"""
mutable struct Talairach <: Coordinate
    x::Number
    y::Number
    z::Number
end

"""
Type for SPM coordinate system.
"""
mutable struct SPM <: Coordinate
    x::Number
    y::Number
    z::Number
end

"""
Type to be used when the coordinate system is unknown.
"""
mutable struct UnknownCoordinate <: Coordinate
    x::Number
    y::Number
    z::Number
end


import Base.show
function show(c::S) where {S<:Coordinate}
    println("Coordinate: $(typeof(c)) - ($(c.x), $(c.y), $(c.z))")
end
