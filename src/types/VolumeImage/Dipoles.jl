function find_dipoles(vi::VolumeImage; kwargs...)

    Logging.info("Finding dipoles for volume image")

    if size(vi.data, 4) > 1
        warn("Can not squeeze 4d volume image to 3d. Please reduce first.")
    end

    x = [xi / (1 * Meter) for xi in vi.x]
    y = [yi / (1 * Meter) for yi in vi.y]
    z = [zi / (1 * Meter) for zi in vi.z]

    # List comprehension returns type any which needs to be changed
    x = convert(Array{AbstractFloat}, x)
    y = convert(Array{AbstractFloat}, y)
    z = convert(Array{AbstractFloat}, z)

    unique_dipoles(find_dipoles(squeeze(vi.data, 4), x=x, y=y, z=z; kwargs...))
end



function new_dipole_method(vi::VolumeImage; min_size::Real = 1, kwargs...)

    old_dips = find_dipoles(vi; kwargs...)

    new_dips = Dipole[]

    for dip in old_dips

        threshold = 0.9 * dip.size

        tmp_vi = deepcopy(vi)

        tmp_vi.data[tmp_vi.data .< threshold] = 0

        val_x = abs.(tmp_vi.x .- (dip.x) ) .> (0.015 * Meter)
        val_y = abs.(tmp_vi.y .- (dip.y) ) .> (0.015 * Meter)
        val_z = abs.(tmp_vi.z .- (dip.z) ) .> (0.015 * Meter)

        tmp_vi.data[val_x, :, :] = 0
        tmp_vi.data[:, val_y, :] = 0
        tmp_vi.data[:, :, val_z] = 0

        valid = tmp_vi.data .> threshold;

        x_loc = mean(vi.x[find(squeeze(sum(valid, [2, 3]), (2, 3)))]  / (1.0 * SIUnits.Meter))
        y_loc = mean(vi.y[find(squeeze(sum(valid, [1, 3]), (1, 3)))]  / (1.0 * SIUnits.Meter))
        z_loc = mean(vi.z[find(squeeze(sum(valid, [1, 2]), (1, 2)))]  / (1.0 * SIUnits.Meter))

        x, y, z, t = find_location(vi, x_loc, y_loc, z_loc)
        s = vi.data[x, y, z, t]

        push!(new_dips, Dipole("Talairach", x_loc, y_loc, z_loc, 0, 0, 0, 0, 0, s))
    end

    new_dips = new_dips[find([d.size > min_size for d in new_dips])]

    unique_dipoles(new_dips)
end

unique_dipoles(dips = Array{Dipoles}) = dips[find(.![false; diff([d.size for d in dips]) .== 0])]

lowest_dipole(dips = Array{Dipoles}) = dips[find([d.z for d in dips] .== minimum([d.z for d in dips]))]
