abstract type Coordinate end

mutable struct BrainVision <: Coordinate
    x::Number
    y::Number
    z::Number
end

mutable struct Talairach <: Coordinate
    x::Number
    y::Number
    z::Number
end

mutable struct SPM <: Coordinate
    x::Number
    y::Number
    z::Number
end

mutable struct UnknownCoordinate <: Coordinate
    x::Number
    y::Number
    z::Number
end


import Base.show
function show(c::S) where S <: Coordinate
    println("Coordinate: $(typeof(c)) - ($(c.x), $(c.y), $(c.z))")
end
