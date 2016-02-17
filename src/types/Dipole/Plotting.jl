function EEG.plot(p, dip::Union{Dipole, Coordinate}; c=:green, m=(8, :rect), l="")

  Plots.scatter!(p.plts[1], [float(dip.x)*1000], [float(dip.y)*1000], m=m, c=c, lab=l, legend=false)
  Plots.scatter!(p.plts[2], [float(dip.y)*1000], [float(dip.z)*1000], m=m, c=c, lab=l, legend=false)
  Plots.scatter!(p.plts[3], [float(dip.x)*1000], [float(dip.z)*1000], m=m, c=c, lab=l, legend=true)

  return p
end


function EEG.plot(p, dips::Union{Array{Dipole}, Array{Coordinate}}; kwargs...)

  for dip in dips
    p = EEG.plot(p, dip; kwargs...)
  end

  return p
end

