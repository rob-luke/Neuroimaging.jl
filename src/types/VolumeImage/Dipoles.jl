function find_dipoles(vi::VolumeImage)

    if size(vi.data, 4) > 1
        warn("Can not squeeze 4d volume image to 3d. Please reduce first.")
    end

    x = float([xi.val for xi in vi.x])
    y = float([yi.val for yi in vi.y])
    z = float([zi.val for zi in vi.z])

    find_dipoles(float(squeeze(vi.data, 4)), x=x, y=y, z=z)
end
