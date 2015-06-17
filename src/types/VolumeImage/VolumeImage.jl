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
end


#
# Basic operations
# ----------------
#


import Base: +, -, /, show, mean

function Base.show(io::IO, vi::VolumeImage)

    println(io, "VolumeImage of method $(vi.method) and units $(vi.units)")
    println(io, "  Spanning x: $(round(vi.x[1], 3)) : $(round(vi.x[end], 3)) m")
    println(io, "  Spanning y: $(round(vi.y[1], 3)) : $(round(vi.y[end], 3)) m")
    println(io, "  Spanning z: $(round(vi.z[1], 3)) : $(round(vi.z[end], 3)) m")
    println(io, "  Spanning t: $(round(vi.t[1], 3)) : $(round(vi.t[end], 3)) s")

    if haskey(vi.info, "Regularisation")
        println(io, "  Regularisation: $(vi.info["Regularisation"])")
    end
end



# +

function +(vi1::VolumeImage, vi2::VolumeImage)

    dimensions_equal(vi1, vi2)

    vi1.data = vi1.data .+ vi2.data

    return vi1
end


# -

function -(vi1::VolumeImage, vi2::VolumeImage)

    dimensions_equal(vi1, vi2)

    vi1.data = vi1.data .- vi2.data

    return vi1
end


# /

function /(vi1::VolumeImage, vi2::VolumeImage)

    dimensions_equal(vi1, vi2)

    vi1.data = vi1.data ./ vi2.data

    return vi1
end


function /(vi1::VolumeImage, c::Number)

    vi1.data = vi1.data ./ c

    return vi1
end


# mean

function mean(vi1::VolumeImage)

    vi1.data = mean(vi1.data, 4)

    # Store time as 0 to indicate its been averaged
    vi1.t = [NaN]

    return vi1
end


#
# Helper functions
# ----------------
#

function dimensions_equal(vi1::VolumeImage, vi2::VolumeImage)

    if (vi1.x == vi2.x) & (vi1.y == vi2.y) & (vi1.z == vi2.z) & (vi1.t == vi2.t) & (vi1.units == vi2.units)
        return true
    else
        error("VolumeImage dimensions do not match")
    end
end
