abstract Coordinate

type BrainVision <: Coordinate
    x::Number
    y::Number
    z::Number
end

type Talairach <: Coordinate
    x::Number
    y::Number
    z::Number
end

type SPM <: Coordinate
    x::Number
    y::Number
    z::Number
end

type UnknownCoordinate <: Coordinate
    x::Number
    y::Number
    z::Number
end


import Base.show
function show{S <: Coordinate}(c::S)
    println("Coordinate: $(typeof(c)) - ($(c.x), $(c.y), $(c.z))")
end
