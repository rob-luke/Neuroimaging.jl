using Leadfield

type Locations
    x::Vector
    y::Vector
    z::Vector
    coordinate_system::String
end



type HeadModel
    surface::Locations          # Shape of surface containing sources
    electrodes::Array{String}   # Name of surface electrodes
    locations::Locations        # Location of sources
    neighbours::Array           # Which sources are your neighbours
    leadfield::Array            # Leadfield between electrodes and locations
    coordinate_system::String
end


function import_headmodel(srf_file::String, elec_file::String, loc_file::String, lft_file::String; verbose=false)

    if verbose
        println("Surface data in file $srf_file")
        println("Electrode data in file $elec_file")
        println("Location data in file $loc_file")
        println("Leadfield data in file $lft_file")
    end

    srf = Locations(readSRF(srf_file, verbose=verbose))

    # Elec

    positions, neigh = readLOC(loc_file, verbose=verbose)

    loc = Locations(positions[:,1], positions[:,2], positions[:,3])

    lft = readLFT(lft_file, verbose=verbose)

    hm = HeadModel(srf, [], loc, neigh, lft, "Talairach")






end
