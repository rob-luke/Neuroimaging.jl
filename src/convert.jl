# Convert things
#
# conv_bv2tal
# conv_spm_mni2tal
#


#######################################
#
# Convert brain vision to talairach
#
#######################################

function conv_bv2tal(Xbv::Union(AbstractArray, Number), Ybv::Union(AbstractArray, Number), Zbv::Union(AbstractArray, Number); verbose::Bool=false, offset::Number=128)

    X = -Zbv .+ offset
    Y = -Xbv .+ offset
    Z = -Ybv .+ offset

    if verbose
        println("Converted $(length(Xbv)) coordinates to talairach space from BV")
    end

    return X, Y, Z
end


#######################################
#
# Convert MNI to talairach
#
#######################################

function conv_spm_mni2tal(Xspm::Union(AbstractArray, Number), Yspm::Union(AbstractArray, Number), Zspm::Union(AbstractArray, Number); verbose::Bool=false)

    # Convert MNI ICMB152 coordinates as used in spm99 to talairach
    # http://www3.interscience.wiley.com/cgi-bin/abstract/114104479/ABSTRACT
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

    if verbose
        println("point 1 x = $(Xspm[1])")
    end

    X = inpoints[1, :]'
    Y = inpoints[2, :]'
    Z = inpoints[3, :]'

    if verbose
        println("point 1 x = $(X[1])")
    end

    if verbose
        println("Converted $(length(X)) coordinates to talairach space from SPM MNI")
    end

    return X, Y, Z
end

function conv_spm_mni2tal(elec::Electrodes; verbose::Bool=false)

    elecNew = elec

    elecNew.xloc, elecNew.yloc, elecNew.zloc = conv_spm_mni2tal(elec.xloc, elec.yloc, elec.zloc, verbose=verbose)

    elecNew.coord_system = "Talairach"

    return elecNew
end


