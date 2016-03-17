using Plots
using SIUnits

function plot(v::VolumeImage; kwargs...)

    x = AbstractFloat[xi / (1 * Milli * Meter) for xi in v.x]
    y = AbstractFloat[yi / (1 * Milli * Meter) for yi in v.y]
    z = AbstractFloat[zi / (1 * Milli * Meter) for zi in v.z]

    plot_src(squeeze(v.data, 4), x, y, z; kwargs...)
end


function plot_src{A <: AbstractFloat}(d::Array{A, 3}, x::Vector{A}, y::Vector{A}, z::Vector{A}; exclude::A=0.0, kwargs...)

    d_out = A[]
    x_out = A[]
    y_out = A[]
    z_out = A[]

    B = sub(d, 1:size(d, 1), 1:size(d, 2), 1:size(d, 3))
    for i in eachindex(B)
        if d[i] != exclude
            push!(d_out, d[i])
            push!(x_out, x[i.I[1]])
            push!(y_out, y[i.I[2]])
            push!(z_out, z[i.I[3]])
        end
    end

    plot_src(d_out, x_out, y_out, z_out; kwargs...)
end


function plot_src{A <: AbstractFloat, S <: AbstractString}(d::Vector{A}, x::Vector{A}, y::Vector{A}, z::Vector{A};
                  title::S="", threshold::Real=-Inf, min_val::Real=Inf, max_val::Real=-Inf, elp::AbstractString="", minsize::Real=3, maxsize::Real=6, kwargs...)

    d = copy(vec(d))
    x = copy(vec(x))
    y = copy(vec(y))
    z = copy(vec(z))

    cols = [colorant"darkblue", colorant"orange", colorant"darkred"]

    if min_val < minimum(d)
        # Specify a minimum point to plot
        Logging.debug("Manually specifying minimum plotting value")
        push!(d, min_val)
        push!(x, 200)
        push!(z, 200)
        push!(y, 200)
    end

    if max_val > maximum(d)
        Logging.debug("Manually specifying maximum plotting value")
        push!(d, max_val)
        push!(x, -200)
        push!(y, -200)
        push!(z, -200)
    end

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
    for x_i in unique(x)
        for y_i in unique(y)
            idxs = (x .== x_i) & (y .== y_i)
            if sum(idxs) > 0
                val = maximum(d[idxs])
                push!(x_tmp, x_i)
                push!(y_tmp, y_i)
                if val > threshold
                    push!(s_tmp, max(scaleval * val, minsize))
                else
                    push!(s_tmp, minsize)
                end
                push!(c_tmp, val)
            end
        end
    end
    p = subplot!(x_tmp, y_tmp, zcolor=c_tmp, c=cols, ms=s_tmp, legend=false, l=:scatter, lab = "Source", colorbar = false, markerstrokewidth = 0.1)
    if plot_labels
        plotlist = ["Fpz", "Fp2", "AF8", "F8", "FT8", "T8", "TP8", "P10", "PO8", "O2", "Oz", "O1", "PO7", "P9", "TP7", "T7", "FT7", "F7", "AF7", "Fp1"]
        for elec in 1:length(e.x)
            if findfirst(plotlist, e.label[elec]) > 0
                annotate!(p.plts[1], e.x[elec]-5, 1.1*e.y[elec]-2, e.label[elec], colorbar = false)
            end
        end
    end

    x_tmp = AbstractFloat[]
    y_tmp = AbstractFloat[]
    c_tmp = AbstractFloat[]
    s_tmp = AbstractFloat[]
    for y_i in unique(y)
        for z_i in unique(z)
            idxs = (z .== z_i) & (y .== y_i)
            if sum(idxs) > 0
                val = maximum(d[idxs])
                push!(x_tmp, y_i)
                push!(y_tmp, z_i)
                if val > threshold
                    push!(s_tmp, max(scaleval * val, minsize))
                else
                    push!(s_tmp, minsize)
                end
                push!(c_tmp, val)
            end
        end
    end
    p = subplot!(p, x_tmp, y_tmp, zcolor=c_tmp, c=cols, ms=s_tmp, legend=false, l=:scatter, lab = "Source", colorbar = false, markerstrokewidth = 0.1)
    if plot_labels
        plotlist = ["Iz", "Oz", "POz", "Pz", "CPz", "Cz", "FCz", "Fz", "AFz", "Fpz"]
        for elec in 1:length(e.x)
            if findfirst(plotlist, e.label[elec]) > 0
                annotate!(p.plts[2], e.y[elec]-5, e.z[elec], e.label[elec])
            end
        end
    end

    x_tmp = AbstractFloat[]
    y_tmp = AbstractFloat[]
    c_tmp = AbstractFloat[]
    s_tmp = AbstractFloat[]
    for x_i in unique(x)
        for z_i in unique(z)
            idxs = (x .== x_i) & (z .== z_i)
            if sum(idxs) > 0
                val = maximum(d[idxs])
                push!(x_tmp, x_i)
                push!(y_tmp, z_i)
                if val > threshold
                    push!(s_tmp, max(scaleval * val, minsize))
                else
                    push!(s_tmp, minsize)
                end
                push!(c_tmp, val)
            end
        end
    end
    p = subplot!(p, x_tmp, y_tmp, zcolor=c_tmp, c=cols, ms=s_tmp, legend=false, l=:scatter, lab = "", markerstrokewidth = 0.1)
    if plot_labels
        plotlist = ["T7", "C5", "C3", "C1", "Cz", "C2", "C4", "C6", "T8"]
        for elec in 1:length(e.x)
            if findfirst(plotlist, e.label[elec]) > 0
                annotate!(p.plts[3], e.x[elec]-5, e.z[elec], e.label[elec])
            end
        end
    end
    if backend() == Plots.PyPlotPackage()
        cb = PyPlot.colorbar(p.plts[1].seriesargs[1][:serieshandle])
        cb[:set_label]("Neural Activity Index")
    end

    return p
end

