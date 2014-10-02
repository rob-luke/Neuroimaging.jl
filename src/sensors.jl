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


#######################################
#
# Standard electrode sets
#
#######################################


EEG_64_10_20 = ["Fp1", "F3", "FC5", "C3", "CP5", "P3", "PO7", "Oz", "Fpz", "AFz", "F6", "FC4", "C2", "TP8", "P2", "P10", "AF7", "F5", "FC3", "C5", "CP3", "P5", "PO3", "POz", "Fp2", "Fz", "F8", "FC2", "C4", "CP6", "P4", "PO8", "AF3", "F7", "FC1", "T7", "CP1", "P7", "O1", "Pz", "AF8", "F2", "FT8", "FCz", "C6", "CP4", "P6", "PO4", "F1", "FT7", "C1", "TP7", "P1", "P9", "Iz", "CPz", "AF4", "F4", "FC6", "Cz", "T8", "CP2", "P8", "O2"]

EEG_Vanvooren_2014 = ["TP7", "P9", "P7", "P5", "P3", "P1", "PO7", "PO3", "O1", "P2", "P4", "P6", "P10", "TP8", "PO4", "PO8", "O2", "TP8"]

EEG_Vanvooren_2014_Left  = ["TP7", "P9", "P7", "P5", "P3", "P1", "PO7", "PO3", "O1"]

EEG_Vanvooren_2014_Right = ["P2", "P4", "P6", "P10", "TP8", "PO4", "PO8", "O2", "TP8"]
