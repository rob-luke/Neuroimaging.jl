"""
Dipole type.


#### Parameters

* coord_system: The coordinate system that the locations are stored in
* x,y,z: Location of dipole
* x,y,z/ori: Orientation of dipole
* color: Color of dipole for plotting
* state: State of dipol
* size: size of dipole

"""
mutable struct Dipole
    coord_system::AbstractString
    x::typeof(1.0u"m")
    y::typeof(1.0u"m")
    z::typeof(1.0u"m")
    xori::Number
    yori::Number
    zori::Number
    color::Number
    state::Number
    size::Number
end


import Base.show
function Base.show(io::IO, d::Dipole)
    @printf("Dipole with coordinates x = % 6.2f m, y = % 6.2f m, z = % 6.2f m, size = % 9.5f\n",
        ustrip(d.x), ustrip(d.y), ustrip(d.z), ustrip(d.size))
end


function Base.show(io::IO, dips::Array{Dipole})
    @printf("%d dipoles\n", length(dips))
    for d in dips
        @printf("  Dipole with coordinates x = % 6.2f m, y = % 6.2f m, z = % 6.2f m and size = % 9.5f\n",
            ustrip(d.x), ustrip(d.y), ustrip(d.z), ustrip(d.size))
    end
end
