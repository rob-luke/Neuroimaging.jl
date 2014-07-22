using Leadfield
using Distance

#
# leadfield is defined in another module
#
# type leadfield
#     L::Array
#     x::Vector
#     y::Vector
#     z::Vector
#     sensors::Array{String}
# end
#


function match_leadfield(l::leadfield, s::ASSR; verbose::Bool=false)

    if verbose; println("Matching leadfield to ASSR"); end

    idx = [findfirst(l.sensors, name) for name = s.header["chanLabels"]]

    if length(unique(idx)) < length(idx); error("Not all ASSR channels mapped to sensor"); end

    l.L = l.L[:,:,idx]
    l.sensors = l.sensors[idx]

    if verbose; println("matched $(length(idx)) sensors"); end

    return l
end


# Find the index in the leadfield that is closest to specified location
function find_location(l::leadfield, x::Number, y::Number, z::Number; verbose::Bool=false)

    if verbose; println("Find location ($x, $y, $z) in $(size(l.L,1)) sources"); end

    dists = [euclidean([l.x[i], l.y[i], l.z[i]], [x, y, z]) for i = 1:length(l.x)]

    idx = findfirst(dists, minimum(dists))

    if verbose;println("Matched location is ($(l.x[idx]), $(l.y[idx]), $(l.z[idx])) with distance $(minimum(dists))");end

    return idx
end

function find_location(l::leadfield, d::Union(Dipole, Coordinate); verbose::Bool=false)
    find_location(l, d.x, d.y, d.z, verbose=verbose)
end
