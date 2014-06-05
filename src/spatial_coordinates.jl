
abstract Coordinates


type BrainVision <: Coordinates
    x::AbstractVector
    y::AbstractVector
    z::AbstractVector
end


type Talairach <: Coordinates
    x::Vector
    y::Vector
    z::Vector
end


type SPM <: Coordinates
    x::Vector
    y::Vector
    z::Vector
end



function convert{T}(::Type{Talairach}, f::TFFilter{T})
    k = real(f.b[1])
    b = f.b / k
    z = convert(Vector{Complex{T}}, roots(b))
    p = convert(Vector{Complex{T}}, roots(f.a))
    ZPKFilter(z, p, k)
end

