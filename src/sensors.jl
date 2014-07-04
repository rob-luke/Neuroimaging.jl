type Electrodes
    coord_system::String
    kind::String
    label::Array
    xloc::Array
    yloc::Array
    zloc::Array
end


function show(elec::Electrodes)
    println("Electrodes: $(elec.coord_system) - $(elec.kind) - # $(length(elec.label))")
    for sens = 1:length(elec.label)
        @printf("| %6s | %5.2f | %5.2f | %5.2f |\n", elec.label[sens], elec.xloc[sens], elec.yloc[sens], elec.zloc[sens])
    end
end


function match_sensors(sens::Electrodes, labels::Array{String}; verbose::Bool=false)
    # Match a set of electrodes to those provided
    #
    # usage: lf, valid = match_sensors(electrodes, sensor_labels, verbose=true)

    valid_idx = Int[]
    for label = labels
        matched_idx = findfirst(sens.label, label)
        if matched_idx != 0; push!(valid_idx, matched_idx); end
        #=if verbose=#
            #=println("Label $label matched to $( matched_idx == 0 ? "!! nothing !!" : sens.label[matched_idx])")=#
        #=end=#
    end

    sens.label = sens.label[valid_idx]
    sens.xloc  = sens.xloc[valid_idx]
    sens.yloc  = sens.yloc[valid_idx]
    sens.zloc  = sens.zloc[valid_idx]

    return sens, valid_idx
end


function match_sensors(lf::Array, lf_labels::Array{String}, labels::Array{String}; verbose::Bool=false)
    # Match the sensors in a leadfield array to those provided
    #
    # usage: lf, valid = match_sensors(leadfield, leadfield_labels, sensor_labels, verbose=true)


    valid_idx = Int[]
    for label = labels
        matched_idx = findfirst(lf_labels, label)
        if matched_idx != 0; push!(valid_idx, matched_idx); end
        #=if verbose=#
            #=println("Label $label matched to $( matched_idx == 0 ? "!! nothing !!" : lf_labels[matched_idx])")=#
        #=end=#
    end

    if verbose
        println("Leadfield had $(length(lf_labels)) channels, now has $(length(valid_idx)) channels")
    end

    lf = lf[:,:,valid_idx]
    lf_labels = lf_labels[valid_idx]

    return lf, valid_idx
end


function readELP(fname::String; verbose::Bool=false)

    if verbose
      println("Reading dat file = $fname")
    end

    # Create an empty electrode set
    elec = Electrodes("unknown", "EEG", String[], Float64[], Float64[], Float64[])

    # Read file
    df = readtable(fname, header = false, separator = ' ')

    # Save locations
    elec.xloc = df[:x2]  #TODO: Fix elp locations to 3d
    elec.yloc = df[:x3]

    # Convert label to ascii and remove '
    labels = df[:x1]
    for i = 1:length(labels)
        push!(elec.label, replace(labels[i], "'", "" ))
    end

    if verbose
        println("Imported $(length(elec.xloc)) locations")
        println("Imported $(length(elec.label)) labels")
    end

    return elec
end
