function plot(vi::VolumeImage; ncols::Int = 2, colorbar::Bool = true, colorbar_title::String = vi.units,
    max_size::Union(Number, Nothing) = 1, min_size = 0.2,
    threshold::Number = unique(sort(vec(squeeze(mean(vi.data, 4), 4))))[2], threshold_ratio::Number = 1/1000, kwargs...)

    x = [float(xi) * 1000 for xi in vi.x]
    y = [float(yi) * 1000 for yi in vi.y]
    z = [float(zi) * 1000 for zi in vi.z]
    s = squeeze(mean(vi.data, 4), 4)

    plot_dat(x, y, z, s, threshold_ratio = threshold_ratio, ncols = ncols,
        max_size = max_size, min_size = min_size, threshold = threshold, colorbar = colorbar,
        colorbar_title = colorbar_title, kwargs...)
end
