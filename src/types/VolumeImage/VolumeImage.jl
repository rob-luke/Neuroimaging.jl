@doc """
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

""" ->
type VolumeImage
    data::Array{AbstractFloat}
    units::AbstractString
    x::Array{SIUnits.SIQuantity{AbstractFloat,1,0,0,0,0,0,0,0,0}, 1}  #(m)
    y::Array{SIUnits.SIQuantity{AbstractFloat,1,0,0,0,0,0,0,0,0}, 1}  #(m)
    z::Array{SIUnits.SIQuantity{AbstractFloat,1,0,0,0,0,0,0,0,0}, 1}  #(m)
    t::Array{SIUnits.SIQuantity{AbstractFloat,0,0,1,0,0,0,0,0,0}, 1}  #(s)
    method::AbstractString
    info::Dict
    coord_system::AbstractString
end


#
# Basic operations
# ----------------
#


import Base: show

function Base.show(io::IO, vi::VolumeImage)

    println(io, "VolumeImage of method $(vi.method) and units $(vi.units)")
    println(io, "  Spanning x: $(vi.x[1])) : $(vi.x[end])")
    println(io, "  Spanning y: $(vi.y[1])) : $(vi.y[end])")
    println(io, "  Spanning z: $(vi.z[1])) : $(vi.z[end])")
    println(io, "  Spanning t: $(vi.t[1])) : $(vi.t[end])")

    if haskey(vi.info, "Regularisation")
        println(io, "  Regularisation: $(vi.info["Regularisation"])")
    end
    if haskey(vi.info, "NormalisationConstant")
        println(io, "  Image has been normalised")
    end
end



