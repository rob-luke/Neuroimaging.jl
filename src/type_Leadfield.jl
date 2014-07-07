using Leadfield


type HeadModel
    surface::Coordinates        # Shape of surface containing sources
    electrodes::Array{String}   # Name of surface electrodes
    locations::Coordinates      # Location of sources
    neighbours::Array           # Which sources are your neighbours
    leadfield::Array            # Leadfield between electrodes and locations
    coordinate_system::String
end


function import_headmodel(srfX::


function import_headmodel(elec_file::String, loc_file::String, lft_file::String; verbose=false)

    if verbose
        println("Electrode data in file $elec_file")
        println("Location  data in file $loc_file")
        println("Leadfield data in file $lft_file")
    end

    x, y, z = readSRF(srf_file, verbose=verbose)
    srf     = Talairach(x, y, z)

    positions, neigh = readLOC(loc_file, verbose=verbose)
    loc = Talairach(vec(positions[1,:]), vec(positions[2,:]), vec(positions[3,:]))

    lft = readLFT(lft_file, verbose=verbose)

    #=hm = HeadModel(srf, [], loc, neigh, lft, "Talairach")=#


    if verbose
        println("")
        println("$(length(loc.x)) locations imported")
        println("$(size(lft)[1]) leadfield locations, $(size(lft)[3]) electrodes")
    end



end


