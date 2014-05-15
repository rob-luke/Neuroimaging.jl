
function conv_bv2tal(Xbv::Array, Ybv::Array, Zbv::Array; verbose::Bool=false, offset::Number=128)

    X = -Zbv .+ offset
    Y = -Xbv .+ offset
    Z = -Ybv .+ offset

    if verbose
        println("Converted $(length(Xbv)) coordinates to talairach space from BV")
    end

    return X, Y, Z
end


function conv_spm_mni2tal(Xspm::Array, Yspm::Array, Zspm::Array; verbose::Bool=false)

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


function channelNames_biosemi_1020(original::String; verbose::Bool=false)

    if length(original) == 2
        original = join((original[1], "0", original[2]))
    end

    biosemi_1020 = ["A01" "Fp1"
                    "A05" "F3"
                    "A09" "FC5"
                    "A13" "C3"
                    "A17" "CP5"
                    "A21" "P3"
                    "A25" "PO7"
                    "A29" "Oz"
                    "B01" "Fpz"
                    "B05" "AFz"
                    "B09" "F6"
                    "B13" "FC4"
                    "B17" "C2"
                    "B21" "TP8"
                    "B25" "P2"
                    "B29" "P10"
                    "A02" "AF7"
                    "A06" "F5"
                    "A10" "FC3"
                    "A14" "C5"
                    "A18" "CP3"
                    "A22" "P5"
                    "A26" "PO3"
                    "A30" "POz"
                    "B02" "Fp2"
                    "B06" "Fz"
                    "B10" "F8"
                    "B14" "FC2"
                    "B18" "C4"
                    "B22" "CP6"
                    "B26" "P4"
                    "B30" "PO8"
                    "A03" "AF3"
                    "A07" "F7"
                    "A11" "FC1"
                    "A15" "T7"
                    "A19" "CP1"
                    "A23" "P7"
                    "A27" "O1"
                    "A31" "Pz"
                    "B03" "AF8"
                    "B07" "F2"
                    "B11" "FT8"
                    "B15" "FCz"
                    "B19" "C6"
                    "B23" "CP4"
                    "B27" "P6"
                    "B31" "PO4"
                    "A04" "F1"
                    "A08" "FT7"
                    "A12" "C1"
                    "A16" "TP7"
                    "A20" "P1"
                    "A24" "P9"
                    "A28" "Iz"
                    "A32" "CPz"
                    "B04" "AF4"
                    "B08" "F4"
                    "B12" "FC6"
                    "B16" "Cz"
                    "B20" "T8"
                    "B24" "CP2"
                    "B28" "P8"
                    "B32" "O2"
                    "Status" "Status"]

    idx = findfirst(biosemi_1020, original)

    if idx == 0
        error("Channel $original is unknown")
    end

    converted = biosemi_1020[idx+size(biosemi_1020)[1]]

    if verbose
        println(" $original converted to $converted")
    end

    return converted

end

function channelNames_biosemi_1020(original::Array{String}; verbose::Bool=false)

    converted = Array(String, size(original))

    if verbose
        println("Converting $(length(original)) channels")
    end

    for i = 1:length(original)
        converted[i] = channelNames_biosemi_1020(original[i], verbose=verbose)
    end

    return converted

end
