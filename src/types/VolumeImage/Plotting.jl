using Plots
using SIUnits

function plot(v::VolumeImage; kwargs...)

    x = AbstractFloat[xi / (1 * Milli * Meter) for xi in v.x]
    y = AbstractFloat[yi / (1 * Milli * Meter) for yi in v.y]
    z = AbstractFloat[zi / (1 * Milli * Meter) for zi in v.z]

    plot_src(squeeze(v.data, 4), x, y, z; kwargs...)
end


function plot_src{A <: AbstractFloat, S <: AbstractString}(d::Array{A, 3}, x::Vector{A}, y::Vector{A}, z::Vector{A};
            threshold::Real=-Inf, min_val::Real=Inf, max_val::Real=-Inf, minsize::Real=2, maxsize::Real=6,
            exclude::A=0.0, title::S="", elp::AbstractString="", colorbar::Bool=true, kwargs...)

    cols = [colorant"darkblue", colorant"orange", colorant"darkred"]

    scaleval = maxsize / maximum(d)

    plot_labels = false
    if elp != ""
        e = read_elp(elp)
        plot_labels = true
    end

    subplot(n = 3, nr = 1, xlabel=["Left - Right (mm)" "Posterior - Anterior (mm)" "Left - Right (mm)"], ylabel=["Posterior - Anterior (mm)" "Inferior - Superior (mm)" "Inferior - Superior (mm)"], xlims=[(-100, 100) (-120, 90) (-100, 100)], ylims=[(-120, 90) (-70, 100) (-70, 100)], title=[ "" title ""])

    x_tmp = AbstractFloat[]
    y_tmp = AbstractFloat[]
    c_tmp = AbstractFloat[]
    s_tmp = AbstractFloat[]
    t = copy(d)
    t = maximum(t, 3)
    t = squeeze(t, 3)
    for x_i in 1:size(t, 1)
        for y_i in 1:size(t, 2)
            val = t[x_i, y_i]
            if val != exclude
                push!(x_tmp, x[x_i])
                push!(y_tmp, y[y_i])
                if val > threshold
                    push!(s_tmp, max(scaleval * val, minsize))
                    push!(c_tmp, val)
                else
                    push!(s_tmp, minsize)
                    push!(c_tmp, minsize)
                end
            end
        end
    end
    if max_val > maximum(c_tmp)
        Logging.debug("Manually specifying maximum plotting value")
        push!(s_tmp, max_val)
        push!(c_tmp, max_val)
        push!(x_tmp, -200)
        push!(y_tmp, -200)
    end
    if min_val < minimum(c_tmp)
        Logging.debug("Manually specifying minimum plotting value")
        push!(s_tmp, min_val)
        push!(c_tmp, min_val)
        push!(x_tmp, -200)
        push!(y_tmp, -200)
    end
    p = subplot!(x_tmp, y_tmp, zcolor=c_tmp, c=cols, ms=s_tmp, legend=false, l=:scatter, lab = "Source", colorbar = false, markerstrokewidth = 0.1)
    if plot_labels
        plotlist = ["Fpz", "Fp2", "AF8", "F8", "FT8", "T8", "TP8", "P10", "PO8", "O2", "Oz", "O1", "PO7", "P9", "TP7", "T7", "FT7", "F7", "AF7", "Fp1"]
        for elec in e
            if findfirst(plotlist, elec.label) > 0
                annotate!(p.plts[1], elec.coordinate.x-5, 1.1*elec.coordinate.y-2, elec.label, colorbar = false)
            end
        end
    end

    x_tmp = AbstractFloat[]
    y_tmp = AbstractFloat[]
    c_tmp = AbstractFloat[]
    s_tmp = AbstractFloat[]
    t = copy(d)
    t = maximum(t, 1)
    t = squeeze(t, 1)
    for x_i in 1:size(t, 1)
        for y_i in 1:size(t, 2)
            val = t[x_i, y_i]
            if val != exclude
                push!(x_tmp, y[x_i])
                push!(y_tmp, z[y_i])
                if val > threshold
                    push!(s_tmp, max(scaleval * val, minsize))
                    push!(c_tmp, val)
                else
                    push!(s_tmp, minsize)
                    push!(c_tmp, minsize)
                end
            end
        end
    end
    if max_val > maximum(c_tmp)
        Logging.debug("Manually specifying maximum plotting value")
        push!(s_tmp, max_val)
        push!(c_tmp, max_val)
        push!(x_tmp, -200)
        push!(y_tmp, -200)
    end
    if min_val < minimum(c_tmp)
        Logging.debug("Manually specifying minimum plotting value")
        push!(s_tmp, min_val)
        push!(c_tmp, min_val)
        push!(x_tmp, -200)
        push!(y_tmp, -200)
    end
    p = subplot!(p, x_tmp, y_tmp, zcolor=c_tmp, c=cols, ms=s_tmp, legend=false, l=:scatter, lab = "Source", colorbar = false, markerstrokewidth = 0.1)
    if plot_labels
        plotlist = ["Iz", "Oz", "POz", "Pz", "CPz", "Cz", "FCz", "Fz", "AFz", "Fpz"]
        for elec in e
            if findfirst(plotlist, elec.label) > 0
                annotate!(p.plts[2], elec.coordinate.y-5, elec.coordinate.z, elec.label)
            end
        end
    end

    x_tmp = AbstractFloat[]
    y_tmp = AbstractFloat[]
    c_tmp = AbstractFloat[]
    s_tmp = AbstractFloat[]
    t = copy(d)
    t = maximum(t, 2)
    t = squeeze(t, 2)
    for x_i in 1:size(t, 1)
        for y_i in 1:size(t, 2)
            val = t[x_i, y_i]
            if val != exclude
                push!(x_tmp, x[x_i])
                push!(y_tmp, z[y_i])
                if val > threshold
                    push!(s_tmp, max(scaleval * val, minsize))
                    push!(c_tmp, val)
                else
                    push!(s_tmp, minsize)
                    push!(c_tmp, minsize)
                end
            end
        end
    end
    if max_val > maximum(c_tmp)
        Logging.debug("Manually specifying maximum plotting value")
        push!(s_tmp, max_val)
        push!(c_tmp, max_val)
        push!(x_tmp, -200)
        push!(y_tmp, -200)
    end
    if min_val < minimum(c_tmp)
        Logging.debug("Manually specifying minimum plotting value")
        push!(s_tmp, min_val)
        push!(c_tmp, min_val)
        push!(x_tmp, -200)
        push!(y_tmp, -200)
    end
    p = subplot!(p, x_tmp, y_tmp, zcolor=c_tmp, c=cols, ms=s_tmp, legend=false, l=:scatter, lab = "", markerstrokewidth = 0.1)
    if plot_labels
        plotlist = ["T7", "C5", "C3", "C1", "Cz", "C2", "C4", "C6", "T8"]
        for elec in e
            if findfirst(plotlist, elec.label) > 0
                annotate!(p.plts[3], elec.coordinate.x-5, elec.coordinate.z, elec.label)
            end
        end
    end
    if (backend() == Plots.PyPlotBackend()) & colorbar
        cb = PyPlot.colorbar(p.plts[1].seriesargs[1][:serieshandle])
        cb[:set_label]("Neural Activity Index")
    end

    return p
end
