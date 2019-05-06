function EEG.plot(p, dip::Union{Dipole, Coordinate}; c=:green, m=(8, :rect), l="", kwargs...)

  Plots.scatter!(p.subplots[1], [ustrip(dip.x)*1000], [ustrip(dip.y)*1000], m=m, c=c, lab=l, legend=false; kwargs...)
  Plots.scatter!(p.subplots[2], [ustrip(dip.y)*1000], [ustrip(dip.z)*1000], m=m, c=c, lab=l, legend=false; kwargs...)
  Plots.scatter!(p.subplots[3], [ustrip(dip.x)*1000], [ustrip(dip.z)*1000], m=m, c=c, lab=l, legend=true; kwargs...)

  return p
end


function EEG.plot(p, dips::Union{Array{Dipole}, Array{Coordinate}}; l = "", kwargs...)

    for dip in 1:length(dips)
        if dip == length(dips)
            p = EEG.plot(p, dips[dip], l = l; kwargs...)
        else
            p = EEG.plot(p, dips[dip], l = ""; kwargs...)
        end
    end

    return p
end
