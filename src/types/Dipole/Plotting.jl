function Neuroimaging.plot(
    p::Plots.Plot,
    dip::Union{Dipole,Coordinate};
    c = :green,
    m = (8, :rect),
    l = "",
    kwargs...,
)

    Plots.scatter!(
        p.subplots[1],
        [ustrip(dip.x) * 1000],
        [ustrip(dip.y) * 1000],
        m = m,
        c = c,
        lab = l,
        legend = false;
        kwargs...,
    )
    Plots.scatter!(
        p.subplots[2],
        [ustrip(dip.y) * 1000],
        [ustrip(dip.z) * 1000],
        m = m,
        c = c,
        lab = l,
        legend = false;
        kwargs...,
    )
    Plots.scatter!(
        p.subplots[3],
        [ustrip(dip.x) * 1000],
        [ustrip(dip.z) * 1000],
        m = m,
        c = c,
        lab = l,
        legend = true;
        kwargs...,
    )

    return p
end


function Neuroimaging.plot(p::Plots.Plot, dips::Vector{Dipole}; l = "", kwargs...)

    for dip = 1:length(dips)
        if dip == length(dips)
            p = Neuroimaging.plot(p, dips[dip], l = l; kwargs...)
        else
            p = Neuroimaging.plot(p, dips[dip], l = ""; kwargs...)
        end
    end

    return p
end
