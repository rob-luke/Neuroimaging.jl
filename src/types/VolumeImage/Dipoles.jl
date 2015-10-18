function find_dipoles(vi::VolumeImage; kwargs...)

    Logging.info("Finding dipoles for volume image")

    if size(vi.data, 4) > 1
        warn("Can not squeeze 4d volume image to 3d. Please reduce first.")
    end

    x = [xi / (1 * Meter) for xi in vi.x]
    y = [yi / (1 * Meter) for yi in vi.y]
    z = [zi / (1 * Meter) for zi in vi.z]

    # List comprehension returns type any which needs to be changed
    x = convert(Array{FloatingPoint}, x)
    y = convert(Array{FloatingPoint}, y)
    z = convert(Array{FloatingPoint}, z)

    find_dipoles(squeeze(vi.data, 4), x=x, y=y, z=z; kwargs...)
end
