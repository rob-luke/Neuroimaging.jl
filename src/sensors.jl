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


function match_sensors(sens::Electrodes, labels::Array{String})
    # Match a set of electrodes to those provided
    #
    # usage: lf, valid = match_sensors(electrodes, sensor_labels)

    valid_idx = Int[]
    for label = labels
        matched_idx = findfirst(sens.label, label)
        if matched_idx != 0; push!(valid_idx, matched_idx); end
        debug("Label $label matched to $( matched_idx == 0 ? "!! nothing !!" : sens.label[matched_idx])")
    end

    sens.label = sens.label[valid_idx]
    sens.xloc  = sens.xloc[valid_idx]
    sens.yloc  = sens.yloc[valid_idx]
    sens.zloc  = sens.zloc[valid_idx]

    return sens, valid_idx
end


function match_sensors(lf::Array, lf_labels::Array{String}, labels::Array{String})
    # Match the sensors in a leadfield array to those provided
    #
    # usage: lf, valid = match_sensors(leadfield, leadfield_labels, sensor_labels)

    valid_idx = Int[]
    for label = labels
        matched_idx = findfirst(lf_labels, label)
        if matched_idx != 0; push!(valid_idx, matched_idx); end
        debug("Label $label matched to $( matched_idx == 0 ? "!! nothing !!" : lf_labels[matched_idx])")
    end

    info("Leadfield had $(length(lf_labels)) channels, now has $(length(valid_idx)) channels")

    lf = lf[:,:,valid_idx]
    lf_labels = lf_labels[valid_idx]

    return lf, valid_idx
end


