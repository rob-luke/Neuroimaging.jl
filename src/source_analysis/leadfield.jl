using Distances

#
# leadfield is defined in another module
#
type leadfield
    L::Array
    x::Vector
    y::Vector
    z::Vector
    sensors::Array{String}
end


function match_leadfield(l, s::ASSR)

    info("Matching leadfield to ASSR")

    idx = [findfirst(l.sensors, name) for name = s.channel_names]

    if length(unique(idx)) < length(idx)
        error("Not all ASSR channels mapped to sensor #ASSR=$(length(s.channel_names)), #L=$(length(l.sensors))")
    end

    l.L = l.L[:,:,idx]
    l.sensors = l.sensors[idx]

    debug("matched $(length(idx)) sensors")

    return l
end


# Find the index in the leadfield that is closest to specified location
function find_location(l, x::Number, y::Number, z::Number)

    info("Find location ($x, $y, $z) in $(size(l.L,1)) sources")

    dists = [euclidean([l.x[i], l.y[i], l.z[i]], [x, y, z]) for i = 1:length(l.x)]

    idx = findfirst(dists, minimum(dists))

    info("Matched location is ($(l.x[idx]), $(l.y[idx]), $(l.z[idx])) with distance $(minimum(dists))")

    return idx
end

function find_location(l, d::Union(Dipole, Coordinate))
    find_location(l, d.x, d.y, d.z)
end
