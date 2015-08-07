@doc doc"""
## Volume Image
This composite type contains volume image information

#### Fields

* `data`: contains the recorded data
* `x`, `y`, `z`, `t` Arrays containing spatial and time information
* `method` String of method used to compute tomography
* `info`: additional information in dictionary

#### `processing` Fields
The following standard names are used when saving data to the info dictionary.
* `Regularisation`: Regularisation used in tomography
* `NormalisationConstant`: Value used to normalise image to maximum of 1
* `FileName`: Name of file

""" ->
type VolumeImage
    data::Array
    units::String
    x::Array{SIUnits.SIQuantity{FloatingPoint,1,0,0,0,0,0,0,0,0}, 1}  #(m)
    y::Array{SIUnits.SIQuantity{FloatingPoint,1,0,0,0,0,0,0,0,0}, 1}  #(m)
    z::Array{SIUnits.SIQuantity{FloatingPoint,1,0,0,0,0,0,0,0,0}, 1}  #(m)
    t::Array{SIUnits.SIQuantity{FloatingPoint,0,0,1,0,0,0,0,0,0}, 1}  #(s)
    method::String
    info::Dict
    coord_system::String
end


#
# Basic operations
# ----------------
#


import Base: +, -, /, *, show, mean, maximum

function Base.show(io::IO, vi::VolumeImage)

    println(io, "VolumeImage of method $(vi.method) and units $(vi.units)")
    println(io, "  Spanning x: $(round(vi.x[1], 3)) : $(round(vi.x[end], 3)) m")
    println(io, "  Spanning y: $(round(vi.y[1], 3)) : $(round(vi.y[end], 3)) m")
    println(io, "  Spanning z: $(round(vi.z[1], 3)) : $(round(vi.z[end], 3)) m")
    println(io, "  Spanning t: $(round(vi.t[1], 3)) : $(round(vi.t[end], 3)) s")

    if haskey(vi.info, "Regularisation")
        println(io, "  Regularisation: $(vi.info["Regularisation"])")
    end
    if haskey(vi.info, "NormalisationConstant")
        println(io, "  Image has been normalised")
    end
end



# +

function +(vi1::VolumeImage, vi2::VolumeImage)

    dimensions_equal(vi1, vi2)

    debug("Adding two volume images with $(size(vi1.data, 4)) time instances")

    vout = deepcopy(vi1)

    vout.data = vi1.data .+ vi2.data

    return vout
end


# -

function -(vi1::VolumeImage, vi2::VolumeImage)

    dimensions_equal(vi1, vi2)

    debug("Subtracting two volume images with $(size(vi1.data, 4)) time instances")

    vout = deepcopy(vi1)

    vout.data = vi1.data .- vi2.data

    return vout
end


# /

function /(vi1::VolumeImage, vi2::VolumeImage)

    dimensions_equal(vi1, vi2)

    debug("Dividing two volume images with $(size(vi1.data, 4)) time instances")

    vout = deepcopy(vi1)

    vout.data = vi1.data ./ vi2.data

    return vout
end

function /(vi::VolumeImage, c::Number)

    vout = deepcopy(vi)

    vout.data = vi.data ./ c

    return vout
end


# *

function *(vi::VolumeImage, c::Number)

    vout = deepcopy(vi)

    vout.data = vi.data .* c

    return vout
end


# mean

function mean(vi::VolumeImage)

    debug("Taking mean of one volume images with $(size(vi.data, 4)) time instances")

    vout = deepcopy(vi)

    vout.data = mean(vout.data, 4)

    # Store time as 0 to indicate its been averaged
    vout.t = [NaN]

    return vout
end

function mean(va::Array{VolumeImage,1})

    debug("Taking mean of $(length(va)) volume images with $(size(va[1].data, 4)) time instances")

    mean_va = deepcopy(va[1])

    for i in 2:length(va)

        mean_va = mean_va + va[i]

    end

    return mean_va / length(va)
end


# maximum

function maximum(vi::VolumeImage)

    maximum(vi.data)
end


# normalise

function normalise(vi::VolumeImage)

    debug("Normalising one volume images with $(size(vi.data, 4)) time instances")

    normalisation_constant = maximum(vi)

    vi = deepcopy(vi) / normalisation_constant

    vi.info["NormalisationConstant"] = normalisation_constant

    return vi
end

function normalise(va::Array{VolumeImage, 1})

    debug("Normalising $(length(va)) volume images with $(size(va[1].data, 4)) time instances")

    vo = deepcopy(va)
    for i in 1:length(vo)
        vo[i] = normalise(vo[i])
    end
    return vo
end


#
# Helper functions
# ----------------
#

function dimensions_equal(vi1::VolumeImage, vi2::VolumeImage; x::Bool=true, y::Bool=true, z::Bool=true, kwargs...)

    matching = true
    if x & !(vi1.x == vi2.x)
        matching = false
    end
    if y & !(vi1.y == vi2.y)
        matching = false
    end
    if z & !(vi1.z == vi2.z)
        matching = false
    end

    if matching
        return true
    else
        error("VolumeImage dimensions do not match")
    end
end
