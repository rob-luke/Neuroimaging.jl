function EEG.oplot(existing_plot::Table, dip::Dipole; plotting_units = 1 / (Milli * Meter), kwargs...)
            
    oplot_dipoles(existing_plot, dip.x * plotting_units, dip.y * plotting_units, dip.z * plotting_units; kwargs...)
end

function EEG.oplot(existing_plot::Table, dips::Array{Dipole}; kwargs...)
            
    for dip in dips
        existing_plot = oplot(existing_plot, dip; kwargs...)
    end
    
    return existing_plot
end
