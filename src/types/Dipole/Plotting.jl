
function oplot(existing_plot::Table, dip::Dipole; plotting_units = Milli * Meter, kwargs...)

    oplot_dipoles(existing_plot, dip.x / plotting_units, dip.y / plotting_units, dip.z / plotting_units; kwargs...)
end
