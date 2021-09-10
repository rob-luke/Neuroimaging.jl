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
    x::typeof(1.0u"m")
    y::typeof(1.0u"m")
    z::typeof(1.0u"m")
    BrainVision(x::AbstractQuantity, y::AbstractQuantity, z::AbstractQuantity) =
        new(x, y, z)
    BrainVision(x::Number, y::Number, z::Number) = new(x * u"m", y * u"m", z * u"m")
end

"""
Type for Talairach coordinate system.
"""
mutable struct Talairach <: Coordinate
    x::typeof(1.0u"m")
    y::typeof(1.0u"m")
    z::typeof(1.0u"m")
    Talairach(x::AbstractQuantity, y::AbstractQuantity, z::AbstractQuantity) = new(x, y, z)
    Talairach(x::Number, y::Number, z::Number) = new(x * u"m", y * u"m", z * u"m")
end

"""
Type for SPM coordinate system.
"""
mutable struct SPM <: Coordinate
    x::typeof(1.0u"m")
    y::typeof(1.0u"m")
    z::typeof(1.0u"m")
    SPM(x::AbstractQuantity, y::AbstractQuantity, z::AbstractQuantity) = new(x, y, z)
    SPM(x::Number, y::Number, z::Number) = new(x * u"m", y * u"m", z * u"m")
end

"""
Type to be used when the coordinate system is unknown.
"""
mutable struct UnknownCoordinate <: Coordinate
    x::typeof(1.0u"m")
    y::typeof(1.0u"m")
    z::typeof(1.0u"m")
    UnknownCoordinate(x::AbstractQuantity, y::AbstractQuantity, z::AbstractQuantity) =
        new(x, y, z)
    UnknownCoordinate(x::Number, y::Number, z::Number) = new(x * u"m", y * u"m", z * u"m")
end


import Base.show
function show(c::S) where {S<:Coordinate}
    println(
        "Coordinate: $(typeof(c)) - ($(c.x |> u"mm"), $(c.y |> u"mm"), $(c.z |> u"mm"))",
    )
end
