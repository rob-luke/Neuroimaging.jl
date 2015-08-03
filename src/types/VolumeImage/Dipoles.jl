function find_dipoles(vi::VolumeImage)

    if size(vi.data, 4) > 1
        warn("Can not squeeze 4d volume image to 3d. Please reduce first.")
    end

    x = float([float(xi) * 1000 for xi in vi.x])
    y = float([float(yi) * 1000 for yi in vi.y])
    z = float([float(zi) * 1000 for zi in vi.z])

    find_dipoles(squeeze(vi.data, 4), x=x, y=y, z=z)
end
