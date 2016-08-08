@doc """
Find all dipole in an activity map.

Determines the local maxima in a 3 dimensional array

#### Input

* s: Activity in 3d matrix
* window: Windowing to use in each dimension for min max filter
* x,y,z: Coordinates associated with s matrix

#### Output

* dips: An array of dipoles

""" ->
function find_dipoles{T <: Number}(s::Array{T, 3}; window::Array{Int}=[6,6,6], x::AbstractVector{T}=1:size(s,1),
                                   y::AbstractVector{T}=1:size(s,2), z::AbstractVector{T}=1:size(s,3))

    debug("Finding dipoles for 3d array")

    minval, maxval = extrema_filter(s, window)

    # Find the positions matching the maxima
    matching = s[2:size(maxval)[1]+1, 2:size(maxval)[2]+1, 2:size(maxval)[3]+1]
    matching = matching .== maxval

    # dipoles are defined as maxima locations and within 90% of the maximum
    peaks = maxval[matching]
    peaks = peaks[peaks .>= 0.1 * maximum(peaks)]

    # Store dipoles in an array
    dips = Dipole[]

    for l = 1:length(peaks)
        xidx, yidx, zidx = ind2sub(size(s), find(s .== peaks[l]))
        push!(dips, Dipole("Unknown", x[xidx[1]], y[yidx[1]], z[zidx[1]], 0, 0, 0, 0, 0, peaks[l]))
    end

    left_side = s[x .< 0, :, :]
    xidx, yidx, zidx = ind2sub(size(left_side), find(left_side .== maximum(left_side)))
    push!(dips, Dipole("Unknown", x[xidx[1]], y[yidx[1]], z[zidx[1]], 0, 0, 0, 0, 0, maximum(left_side)))

    right_side = s[x .> 0, :, :]
    xidx, yidx, zidx = ind2sub(size(right_side), find(right_side .== maximum(right_side)))
    x_tmp = x[x .> 0]
    push!(dips, Dipole("Unknown", x_tmp[xidx[1]], y[yidx[1]], z[zidx[1]], 0, 0, 0, 0, 0, maximum(right_side)))

    # Sort dipoles by size
    vec(dips[sortperm([dip.size for dip in dips], rev=true)])
end


#######################################
#
# Find the best dipoles from selection
#
#######################################


@doc """
Find best dipole relative to reference location.

Finds the largest dipole within a specified distance of a reference location

#### Input

* ref: Reference coordinate or dipole
* dips: Dipoles to find the best dipole from
* maxdist: Maximum distance a dipole can be from the reference

#### Output

* dip: The best dipole

""" ->
function best_dipole(ref::Union{Coordinate, Dipole}, dips::Array{Dipole}; maxdist::Number=0.30, min_dipole_size::Real=-Inf, kwargs...)

    Logging.info("Calculating best dipole for $(length(dips)) dipoles")

    dips = dips[find([d.size > min_dipole_size for d in dips])]

    if length(dips) > 0

      # Find all dipoles within distance
      dists = [euclidean(ref, dip) for dip=dips]
      valid_dist = dists .< maxdist

      if sum(valid_dist) >= 2
          # Valid dipoles exist find the largest one
          sizes = [dip.size for dip =dips]
          bestdip = maximum(sizes[valid_dist])
          dip = dips[find(sizes .== bestdip)]
          debug("$(sum(valid_dist)) dipoles within $(maxdist) m. ")

      elseif sum(valid_dist) == 1
          # Return the one valid dipole
          dip = dips[find(valid_dist)]
          debug("Only one dipole within $(maxdist) m. ")

      else
          # No dipoles within distance
          # Take the closest
          bestdip = minimum(dists)
          dip = dips[find(dists .== bestdip)]
          debug("No dipole within $(maxdist) m. ")

      end
      debug("Best = $(euclidean(ref, dip[1]))")

      return dip[1]

    else
      return NaN
    end
end
