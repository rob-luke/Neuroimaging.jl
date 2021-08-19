using Statistics
function mean(ds::Array{Dipole})

    mean_x = Statistics.mean([d.x for d in ds])
    mean_y = Statistics.mean([d.y for d in ds])
    mean_z = Statistics.mean([d.z for d in ds])
    mean_s = Statistics.mean([d.size for d in ds])

    Dipole(ds[1].coord_system, mean_x, mean_y, mean_z, 0, 0, 0, 0, 0, mean_s)
end

function std(ds::Array{Dipole})

    std_x = Statistics.std([d.x for d in ds])
    std_y = Statistics.std([d.y for d in ds])
    std_z = Statistics.std([d.z for d in ds])
    std_s = Statistics.std([d.size for d in ds])

    Dipole(ds[1].coord_system, std_x, std_y, std_z, 0, 0, 0, 0, 0, std_s)
end
