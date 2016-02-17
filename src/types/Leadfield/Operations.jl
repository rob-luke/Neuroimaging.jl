"""
Find index of location of coordinate or dipole in leadfield
"""
find_location(l, d::Union{Dipole, Coordinate}) = find_location(l, d.x, d.y, d.z)


function find_location(l, x::Number, y::Number, z::Number)

    valid_x = l.x .== x
    valid_y = l.y .== y
    valid_z = l.z .== z

    find(valid_x & valid_y & valid_z)[1]
end
