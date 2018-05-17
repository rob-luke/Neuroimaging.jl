#######################################
#
# rba file
#
#######################################

@doc """
Read rba from MAT file
""" ->
function read_rba_mat(mat_path)
    # Define variables here so that they can be accessed within the scope of try constructs
    modulation_frequency  = NaN
    stimulation_amplitude = NaN
    stimulation_side      = ""
    participant_name      = ""
    carrier_frequency     = NaN

    # Old RBA format
    try
        rba = matread(mat_path)

        modulation_frequency = rba["properties"]["stimulation_properties"]["stimulus_1"]["rounded_modulation_frequency"]
        carrier_frequency    = rba["properties"]["stimulation_properties"]["stimulus_1"]["rounded_carrier_frequency"]

        info("Imported matching .mat file in old format")
    end

    # New RBA format
    try
        rba = matopen(mat_path)
        mat = read(rba, "properties")

        modulation_frequency1 = mat["stimulation_properties"]["stimulus_1"]["rounded_modulation_frequency"]
        modulation_frequency2 = mat["stimulation_properties"]["stimulus_2"]["rounded_modulation_frequency"]

        carrier_frequency = mat["stimulation_properties"]["stimulus_1"]["rounded_carrier_frequency"]

        if modulation_frequency1 != modulation_frequency2
            err("Different modulation frequency in each stimulus. Taking stimulus 1")
        end
        modulation_frequency  = modulation_frequency1

        stimulus_amplitude1 = mat["stimulation_properties"]["stimulus_1"]["amplitude"]
        stimulus_amplitude2 = mat["stimulation_properties"]["stimulus_2"]["amplitude"]
        if stimulus_amplitude1 == stimulus_amplitude2
            stimulation_side = "Bilateral"
        else
            stimulation_side = stimulus_amplitude1 > stimulus_amplitude2 ? "Left" : "Right"
        end
        stimulation_amplitude = max(stimulus_amplitude1, stimulus_amplitude2)

        participant_name    = mat["metas"]["subject"]

        info("Imported matching .mat file in new format")
    end

    if modulation_frequency == NaN && stimulation_side == NaN && participant_name == NaN
        warn("Reading of .mat file failed")
    end

    debug("Frequency: $modulation_frequency Side: $stimulation_side Name: $participant_name Carrier: $carrier_frequency")

    return modulation_frequency, stimulation_side, participant_name, stimulation_amplitude, carrier_frequency
end
