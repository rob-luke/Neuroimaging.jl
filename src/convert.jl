
function conv_bv2tal(Xbv::Array, Ybv::Array, Zbv::Array; verbose::Bool=false, offset::Number=128)

    X = -Zbv .+ offset
    Y = -Xbv .+ offset
    Z = -Ybv .+ offset

    if verbose
        println("Converted $(length(Xbv)) coordinates to talairach space")
    end

    return X, Y, Z
end

