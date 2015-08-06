function plot(vi::VolumeImage; colorbar_title::String = vi.units, kwargs...)

    debug("Plotting volume image with $(size(vi.data, 4)) time instances")

    x = float([float(xi) * 1000 for xi in vi.x])
    y = float([float(yi) * 1000 for yi in vi.y])
    z = float([float(zi) * 1000 for zi in vi.z])
    s = squeeze(mean(vi.data, 4), 4)

    plot_dat(x, y, z, s, colorbar_title = colorbar_title; kwargs...)
end
