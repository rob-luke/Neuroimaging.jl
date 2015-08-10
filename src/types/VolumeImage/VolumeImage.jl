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
    data::Array{FloatingPoint}
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


import Base: show

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



