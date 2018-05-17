import Base.mean
function mean(ds::Array{Dipole})

    mean_x = mean([d.x for d in ds])
    mean_y = mean([d.y for d in ds])
    mean_z = mean([d.z for d in ds])
    mean_s = mean([d.size for d in ds])

    Dipole(ds[1].coord_system, mean_x, mean_y, mean_z, 0, 0, 0, 0, 0, mean_s)
end

import Base.std
function std(ds::Array{Dipole})

    std_x = std([d.x / Meter for d in ds])
    std_y = std([d.y / Meter for d in ds])
    std_z = std([d.z / Meter for d in ds])
    std_s = std([d.size for d in ds])

    Dipole(ds[1].coord_system, std_x, std_y, std_z, 0, 0, 0, 0, 0, std_s)
end
