using MinMaxFilter


type Dipole
    coord_system::String
    x::Number
    y::Number
    z::Number
    xori::Number
    yori::Number
    zori::Number
    color::Number
    state::Number
    size::Number
end


#######################################
#
# Find dipoles in source data
#
# Use local maxima as dipoles
#
#######################################


function find_dipoles(s::Array{FloatingPoint, 3}; window::Array{Int}=[6,6,6],
                      x=1:size(s,1), y=1:size(s,2),
                      z=1:size(s,3), t=1:size(s,4))

    info("3d dipole finding")

    minval, maxval = minmax_filter(s, window, verbose=false)

    # Find the positions matching the maxima
    matching = s[2:size(maxval)[1]+1, 2:size(maxval)[2]+1, 2:size(maxval)[3]+1]
    matching = matching .== maxval

    # dipoles are defined as maxima locations and within 90% of the maximum
    peaks = maxval[matching]
    peaks = peaks[peaks .>= 0.1 * maximum(peaks)]

    dips = Array(Dipole, (1,length(peaks)))
    for l = 1:length(peaks)
        xidx, yidx, zidx = ind2sub(size(s), find(s .== peaks[l]))

        dips[l] = Dipole("Unknown", x[xidx[1]], y[yidx[1]], z[zidx[1]],
                         0, 0, 0, 0, 0,
                         peaks[l])

    end

    return dips
end


function find_dipoles(s::Array{FloatingPoint, 4}; window::Array{Int}=[6,6,6,20],
                      x=1:size(s,1), y=1:size(s,2),
                      z=1:size(s,3), t=1:size(s,4))

    info("4d dipole finding")

    minval, maxval = minmax_filter(s, window, verbose=false)

    # Find the positions matching the maxima
    matching = s[2:size(maxval)[1]+1, 2:size(maxval)[2]+1, 2:size(maxval)[3]+1, 2:size(maxval)[4]+1]
    matching = matching .== maxval

    # dipoles are defined as maxima locations and within 90% of the maximum
    peaks = maxval[matching]
    peaks = peaks[peaks .>= 0.1 * maximum(peaks)]

    dips = Array(Dipole, (1,length(peaks)))
    for l = 1:length(peaks)
        xidx, yidx, zidx, tidx = ind2sub(size(s), find(s .== peaks[l]))

        dips[l] = Dipole("Unknown", x[xidx[1]], y[yidx[1]], z[zidx[1]],
                         0, 0, 0, 0, 0,
                         peaks[l])

    end

    return dips
end


#######################################
#
# Find the best dipoles from selection
#
#######################################


#
# Euclidean distance for coordinates and dipoles
#

import Distances.euclidean
function euclidean(a::Union(Coordinate, Dipole), b::Union(Coordinate, Dipole))
    euclidean([a.x, a.y, a.z], [b.x, b.y, b.z])
end


#
# Determine the best dipole
# Takes the largest sized dipole within set distance from reference coordinates
#

function best_dipole(ref::Coordinate, dips::Array{Dipole}; maxdist::Number=30)

    info("Calculating best dipole for $(length(dips)) dipoles")

    # Find all dipoles within distance
    dists = [euclidean(ref, dip) for dip=dips]
    valid_dist = dists .< maxdist

    if sum(valid_dist) >= 2
        # Valid dipoles exist find the largest one
        sizes = [dip.size for dip =dips]
        bestdip = maximum(sizes[valid_dist])
        dip = dips[find(sizes .== bestdip)]
        debug("$(sum(valid_dist)) dipoles within $(maxdist)mm. ")
    elseif sum(valid_dist) == 1
        # Return the one valid dipole
        dip = dips[find(valid_dist)]
        debug("Only one dipole within $(maxdist)mm. ")
    else
        # No dipoles within distance
        # Take the closest
        bestdip = minimum(dists)
        dip = dips[find(dists .== bestdip)]
        debug("No dipole within $(maxdist)mm. ")
    end
    debug("Best = $(euclidean(ref, dip[1]))")

    return dip[1]
end
