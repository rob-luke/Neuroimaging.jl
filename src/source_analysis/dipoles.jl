"""
Find all dipole in an activity map.

Determines the local maxima in a 3 dimensional array

#### Input

* s: Activity in 3d matrix
* window: Windowing to use in each dimension for min max filter
* x,y,z: Coordinates associated with s matrix

#### Output

* dips: An array of dipoles

"""
function find_dipoles(s::Array{T, 3}; window::Array{Int}=[6,6,6], x::AbstractVector{T}=1:size(s,1),
                      y::AbstractVector{T}=1:size(s,2), z::AbstractVector{T}=1:size(s,3)) where T <: Number

    @debug("Finding dipoles for 3d array")

    localmaxima_locations = findlocalmaxima(s)
    peak_values = s[localmaxima_locations]
    smallest_peak_value = (0.1 * maximum(peak_values))
    localmaxima_locations_subset = findlocalmaxima(s .>= smallest_peak_value)
    localmaxima_locations_subset = localmaxima_locations

    # Store dipoles in an array
    dips = Dipole[]

    for location in localmaxima_locations_subset
        push!(dips, Dipole("Unknown", location[1] * u"m", location[2] * u"m", location[3] * u"m", 0, 0, 0, 0, 0, s[location]))
    end

    left_side = s[x .< 0, :, :]
    a = CartesianIndices(size(left_side))[findall(left_side .== maximum(left_side))]
    a = a[1]
    xidx = a[1]
    yidx = a[2]
    zidx = a[3]
    push!(dips, Dipole("Unknown", x[xidx[1]] * u"m", y[yidx[1]] * u"m", z[zidx[1]] * u"m", 0, 0, 0, 0, 0, maximum(left_side)))

    right_side = s[x .> 0, :, :]
    a = CartesianIndices(size(right_side))[findall(right_side .== maximum(right_side))]
    a = a[1]
    xidx = a[1]
    yidx = a[2]
    zidx = a[3]
    x_tmp = x[x .> 0]
    push!(dips, Dipole("Unknown", x_tmp[xidx[1]] * u"m", y[yidx[1]] * u"m", z[zidx[1]] * u"m", 0, 0, 0, 0, 0, maximum(right_side)))

    # Sort dipoles by size
    vec(dips[sortperm([dip.size for dip in dips], rev=true)])
end


#######################################
#
# Find the best dipoles from selection
#
#######################################


"""
Find best dipole relative to reference location.

Finds the largest dipole within a specified distance of a reference location

#### Input

* ref: Reference coordinate or dipole
* dips: Dipoles to find the best dipole from
* maxdist: Maximum distance a dipole can be from the reference

#### Output

* dip: The best dipole

"""
function best_dipole(ref::Union{Coordinate, Dipole}, dips::Array{Dipole}; maxdist::Number=0.30, min_dipole_size::Real=-Inf, kwargs...)

    @info("Calculating best dipole for $(length(dips)) dipoles")

    dips = dips[findall([d.size > min_dipole_size for d in dips])]

    if length(dips) > 0

      # Find all dipoles within distance
      dists = [euclidean(ref, dip) for dip=dips]
      valid_dist = dists .< maxdist

      if sum(valid_dist) >= 2
          # Valid dipoles exist find the largest one
          sizes = [dip.size for dip =dips]
          bestdip = maximum(sizes[valid_dist])
          dip = dips[findall(sizes .== bestdip)]
          @debug("$(sum(valid_dist)) dipoles within $(maxdist) m. ")

      elseif sum(valid_dist) == 1
          # Return the one valid dipole
          dip = dips[findall(valid_dist)]
          @debug("Only one dipole within $(maxdist) m. ")

      else
          # No dipoles within distance
          # Take the closest
          bestdip = minimum(dists)
          dip = dips[findall(dists .== bestdip)]
          @debug("No dipole within $(maxdist) m. ")

      end
      @debug("Best = $(euclidean(ref, dip[1]))")

      return dip[1]

    else
      return NaN
    end
end
