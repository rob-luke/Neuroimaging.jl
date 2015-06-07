@doc doc"""
Dipole type.

Store the location, direction and state of a dipole

#### Parameters

* coord_system: The coordinate system that the locations are stored in
* x,y,z: Location of dipole
* x,y,z/ori: Orientation of dipole
* color: Color of dipole for plotting
* state: State of dipol
* size: size of dipole

""" ->
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


import Base.show
function Base.show(io::IO, d::Dipole)
    @printf("Dipole with coordinates x=% 6.2f, y=% 6.2f, z=% 6.2f, size=% 9.5f\n", d.x, d.y, d.z, d.size)
end

#
# Euclidean distance for coordinates and dipoles

import Distances.euclidean
function euclidean(a::Union(Coordinate, Dipole), b::Union(Coordinate, Dipole))
    euclidean([a.x, a.y, a.z], [b.x, b.y, b.z])
end


@doc doc"""
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

    minval, maxval = minmax_filter(s, window, verbose=false)

    # Find the positions matching the maxima
    matching = s[2:size(maxval)[1]+1, 2:size(maxval)[2]+1, 2:size(maxval)[3]+1]
    matching = matching .== maxval

    # dipoles are defined as maxima locations and within 90% of the maximum
    peaks = maxval[matching]
    peaks = peaks[peaks .>= 0.1 * maximum(peaks)]

    # Store dipoles in an array
    dips = Array(Dipole, (1,length(peaks)))

    for l = 1:length(peaks)

        xidx, yidx, zidx = ind2sub(size(s), find(s .== peaks[l]))
        dips[l] = Dipole("Unknown", x[xidx[1]], y[yidx[1]], z[zidx[1]], 0, 0, 0, 0, 0, peaks[l])
    end

    return dips
end


# 4 d version. Not used
function find_dipoles{T <: Number}(s::Array{T, 4}; window::Array{Int}=[6,6,6,20],
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


@doc doc"""
Find best dipole relative to reference location.

Finds the largest dipole within a specified distance of a reference location

#### Input

* ref: Reference coordinate or dipole
* dips: Dipoles to find the best dipole from
* maxdist: Maximum distance a dipole can be from the reference

#### Output

* dip: The best dipole

""" ->
function best_dipole(ref::Union(Coordinate, Dipole), dips::Array{Dipole}; maxdist::Number=30)

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



#######################################
#
# Currently unused functions
#
#######################################

function orient_dipole(dipole_data::Array{FloatingPoint, 2}, triggers, fs::Number, modulation_frequency; kwargs...)

    warn("This function is not used. Check the output carefully")

    #
    # Input:  Signal projected on to orthogonal orientations and necessary parameters
    # Output: Single signal of orientations projected on to SNR optimal vector
    #

    info("Optimising dipole orientation")

    if size(dipole_data, 2) > size(dipole_data, 1)
        debug("Transposing. Channels should be in the second dimension.")
        dipole_data = dipole_data'
    end

    a = SSR(dipole_data, triggers, Dict(), fs * Hertz, modulation_frequency, [""], "", "", ["o1", "o2", "o3"], Dict(), Dict())
    a = extract_epochs(a; kwargs...)
    a = create_sweeps(a; kwargs...)
    a = ftest(a; kwargs...)
    a = a.processing["statistics"][:SNRdB]  # Should save ftest with different name incase statistics already used
    a = a ./ maximum(a)
    a = a ./ sum(a)
    convert(Array, dipole_data * a)
end

function orient_dipole(dipole_data::Array{Float32, 2}, triggers, fs, modulation_frequency; kwargs...)
    orient_dipole(convert(Array{FloatingPoint, 2}, dipole_data), triggers, fs, modulation_frequency; kwargs...)
end

function orient_dipole(dipole_data::Array{Float64, 2}, triggers, fs, modulation_frequency; kwargs...)
    orient_dipole(convert(Array{FloatingPoint, 2}, dipole_data), triggers, fs, modulation_frequency; kwargs...)
end


function best_ftest_dipole(dipole_data::Array{FloatingPoint, 2}, triggers, fs::Number, modulation_frequency; kwargs...)

    warn("This function is not used. Check the output carefully")

    #
    # Input:  Signal projected on to orthogonal orientations and necessary parameters
    # Output: Signal with the largest ftest SNR
    #

    info("Optimising dipole orientation")

    if size(dipole_data, 2) > size(dipole_data, 1)
        debug("Transposing. Channels should be in the second dimension.")
        dipole_data = dipole_data'
    end

    a = SSR(dipole_data, triggers, Dict(), fs * Hertz, modulation_frequency, [""], "", "", ["o1", "o2", "o3"], Dict(), Dict())
    a = extract_epochs(a; kwargs...)
    a = create_sweeps(a; kwargs...)
    a = ftest(a; kwargs...)
    a = a.processing["statistics"][:SNRdB]  # Should save ftest with different name incase statistics already used
    a = vec(float(a .== maximum(a)))
    convert(Array, dipole_data * a)
end

function best_ftest_dipole(dipole_data::Array{Float32, 2}, triggers, fs, modulation_frequency)
    best_ftest_dipole(convert(Array{FloatingPoint, 2}, dipole_data), triggers, fs, modulation_frequency)
end

function best_ftest_dipole(dipole_data::Array{Float64, 2}, triggers, fs, modulation_frequency)
    best_ftest_dipole(convert(Array{FloatingPoint, 2}, dipole_data), triggers, fs, modulation_frequency)
end
