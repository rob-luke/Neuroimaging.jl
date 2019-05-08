"""
Find index of location of coordinate or dipole in leadfield
"""
find_location(l, d::Union{Dipole, Coordinate}) = find_location(l::Leadfield, d.x, d.y, d.z)


function find_location(l::Leadfield, x::Number, y::Number, z::Number)

    valid_x = l.x .== x
    valid_y = l.y .== y
    valid_z = l.z .== z

    idx = findall(valid_x .& valid_y .& valid_z)

    if isempty(idx)

        dists = [euclidean([l.x[i], l.y[i], l.z[i]], [x, y, z]) for i = 1:length(l.x)]
        idx = something(findfirst(isequal(minimum(dists)), dists), 0)
    else
        idx = idx[1]
    end

    return idx
end
