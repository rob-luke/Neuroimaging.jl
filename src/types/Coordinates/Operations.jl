#######################################
#
# Wrapper convert functions
#
#######################################

import Base.convert

function convert(::Type{Talairach}, l::BrainVision)

    x, y, z = conv_bv2tal(l.x, l.y, l.z)

    Talairach(x, y, z)
end


function convert(::Type{Talairach}, l::SPM)

    x, y, z = conv_spm_mni2tal(l.x, l.y, l.z)

    Talairach(x[1], y[1], z[1])
end



#######################################
#
# Convert brain vision to talairach
#
#######################################

function conv_bv2tal(Xbv::Union{AbstractArray, Number}, Ybv::Union{AbstractArray, Number}, Zbv::Union{AbstractArray, Number}; offset::Number=128)

    X = -Zbv .+ offset
    Y = -Xbv .+ offset
    Z = -Ybv .+ offset

    Logging.info("Converted $(length(Xbv)) coordinates to talairach space from BV")

    return X, Y, Z
end


#######################################
#
# Convert MNI to talairach
#
#######################################

function conv_spm_mni2tal(Xspm::Union{AbstractArray, Number}, Yspm::Union{AbstractArray, Number}, Zspm::Union{AbstractArray, Number})

    # Convert MNI ICMB152 coordinates as used in spm99 to talairach
    # http://onlinelibrary.wiley.com/doi/10.1002/hbm.20345/abstract
    # Port of http://www.brainmap.org/icbm2tal/icbm_spm2tal.m

    inpoints = [Xspm Yspm Zspm]'
    inpoints = [inpoints; ones(Float64, (1, size(inpoints)[2]))]

    # Transformation matrices, different for each software package
    icbm_spm = [0.9254 0.0024 -0.0118 -1.0207;
               -0.0048 0.9316 -0.0871 -1.7667;
                0.0152 0.0883  0.8924  4.0926;
                0.0000 0.0000  0.0000  1.0000]

    # apply the transformation matrix
    inpoints = icbm_spm * inpoints

    X = inpoints[1, :]'
    Y = inpoints[2, :]'
    Z = inpoints[3, :]'

    Logging.info("Converted $(length(X)) coordinates to talairach space from SPM MNI")

    return X, Y, Z
end


function conv_spm_mni2tal(elec::Electrode)

    x, y, z = conv_spm_mni2tal(elec.coordinate.x, elec.coordinate.y, elec.coordinate.z)

    Electrode(elec.label, Talairach(x[1], y[1], z[1]), elec.info)
end



# Euclidean distance for coordinates and dipoles

function Distances.euclidean(a::Union{Coordinate, Dipole}, b::Union{Coordinate, Dipole})
    euclidean([float(a.x), float(a.y), float(a.z)], [float(b.x), float(b.y), float(b.z)])
end

function Distances.euclidean(a::Union{Coordinate, Dipole}, b::V) where V <: AbstractVector
    euclidean([float(a.x), float(a.y), float(a.z)], b)
end

function Distances.euclidean(a::V, b::Union{Coordinate, Dipole}) where V <: AbstractVector
    euclidean(a, [float(b.x), float(b.y), float(b.z)])
end

