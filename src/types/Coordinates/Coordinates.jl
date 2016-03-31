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


