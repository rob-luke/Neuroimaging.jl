function plot(vi::VolumeImage; colorbar_title::String = vi.units, plotting_units = Milli * Meter, kwargs...)

    debug("Plotting volume image with $(size(vi.data, 4)) time instances")

    x = float([x / (1 * plotting_units) for x in vi.x])
    y = float([y / (1 * plotting_units) for y in vi.y])
    z = float([z / (1 * plotting_units) for z in vi.z])
    s = squeeze(mean(vi.data, 4), 4)

    if plotting_units == Milli*Meter
        units = "mm"
    else
        units = "??"
    end

    plot_dat(x, y, z, s, colorbar_title = colorbar_title, units = units; kwargs...)
end
