"""
## Volume Image
This composite type contains volume image information

#### Fields

* `data`: contains the recorded data
* `x`, `y`, `z`, `t` Arrays containing spatial and time information
* `method` AbstractString of method used to compute tomography
* `info`: additional information in dictionary

#### `processing` Fields
The following standard names are used when saving data to the info dictionary.
* `Regularisation`: Regularisation used in tomography
* `NormalisationConstant`: Value used to normalise image to maximum of 1
* `FileName`: Name of file

"""
mutable struct VolumeImage
    data::Array{AbstractFloat, 4}
    units::AbstractString
    x::Vector{typeof(1.0u"m")}
    y::Vector{typeof(1.0u"m")}
    z::Vector{typeof(1.0u"m")}
    t::Vector{typeof(1.0u"s")}
    method::AbstractString
    info::Dict
    coord_system::AbstractString

    function VolumeImage(data::Array{F, 4}, units::S,
x::Vector{F}, y::Vector{F}, z::Vector{F}, t::Vector{F},
method::S, info::Dict, coord_system::S) where {F<:AbstractFloat, S<:AbstractString}

        @assert size(data, 1) == length(x)
        @assert size(data, 2) == length(y)
        @assert size(data, 3) == length(z)
        @assert size(data, 4) == length(t)

        new(data, units, x * u"m", y * u"m", z * u"m", t * u"s", method, info, coord_system)
    end

    function VolumeImage(data::Array{F, 4}, units::S,
x::Vector{Met}, y::Vector{Met}, z::Vector{Met}, t::Vector{Sec},
method::S, info::Dict, coord_system::S) where {F<:AbstractFloat, S<:AbstractString, Met<:typeof(1.0u"m"),
                                               Sec<:typeof(1.0u"s")}

        @assert size(data, 1) == length(x)
        @assert size(data, 2) == length(y)
        @assert size(data, 3) == length(z)
        @assert size(data, 4) == length(t)

        new(data, units, x, y, z, t, method, info, coord_system)
    end

    function VolumeImage(data::Vector{F}, units::S,
x::Vector{F}, y::Vector{F}, z::Vector{F}, t::Vector{F},
method::S, info::Dict, coord_system::S) where {F<:AbstractFloat, S<:AbstractString}

        @assert length(x) == length(data)
        @assert length(y) == length(data)
        @assert length(z) == length(data)
        @assert length(t) == length(data)

        newX = sort(unique(x))
        newY = sort(unique(y))
        newZ = sort(unique(z))
        newT = sort(unique(t))

        L = zeros(typeof(data[1]), length(newX), length(newY), length(newZ), length(newT))

        for idx in 1:length(data)
            idxX = something(findfirst(isequal(x[idx]), newX), 0) 
            idxY = something(findfirst(isequal(y[idx]), newY), 0)
            idxZ = something(findfirst(isequal(z[idx]), newZ), 0)
            idxT = something(findfirst(isequal(t[idx]), newT), 0)
            L[idxX, idxY, idxZ, idxT] = data[idx]
        end

        new(L, units, newX * u"m", newY * u"m", newZ * u"m", newT * u"s", method, info, coord_system)
    end

end


#
# Basic operations
# ----------------
#


import Base: show

function Base.show(io::IO, vi::VolumeImage)

    println(io, "VolumeImage of method $(vi.method) and units $(vi.units)")
    println(io, "  Spanning x: $(vi.x[1]) : $(vi.x[end])")
    println(io, "  Spanning y: $(vi.y[1]) : $(vi.y[end])")
    println(io, "  Spanning z: $(vi.z[1]) : $(vi.z[end])")
    println(io, "  Spanning t: $(vi.t[1]) : $(vi.t[end])")

    if haskey(vi.info, "Regularisation")
        println(io, "  Regularisation: $(vi.info["Regularisation"])")
    end
    if haskey(vi.info, "NormalisationConstant")
        println(io, "  Image has been normalised")
    end
end
