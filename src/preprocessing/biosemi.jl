# Deal with BIOSEMI issues
#
# channelNames_biosemi_1020
#


#######################################
#
# Change biosemi labels to 1020
#
#######################################

function channelNames_biosemi_1020(original::String)

    if length(original) == 2
        original = join((original[1], "0", original[2]))
    end

    biosemi_1020 = ["A01" "Fp1"
                    "A05" "F3"
                    "A09" "FC5"
                    "A13" "C3"
                    "A17" "CP5"
                    "A21" "P3"
                    "A25" "PO7"
                    "A29" "Oz"
                    "B01" "Fpz"
                    "B05" "AFz"
                    "B09" "F6"
                    "B13" "FC4"
                    "B17" "C2"
                    "B21" "TP8"
                    "B25" "P2"
                    "B29" "P10"
                    "A02" "AF7"
                    "A06" "F5"
                    "A10" "FC3"
                    "A14" "C5"
                    "A18" "CP3"
                    "A22" "P5"
                    "A26" "PO3"
                    "A30" "POz"
                    "B02" "Fp2"
                    "B06" "Fz"
                    "B10" "F8"
                    "B14" "FC2"
                    "B18" "C4"
                    "B22" "CP6"
                    "B26" "P4"
                    "B30" "PO8"
                    "A03" "AF3"
                    "A07" "F7"
                    "A11" "FC1"
                    "A15" "T7"
                    "A19" "CP1"
                    "A23" "P7"
                    "A27" "O1"
                    "A31" "Pz"
                    "B03" "AF8"
                    "B07" "F2"
                    "B11" "FT8"
                    "B15" "FCz"
                    "B19" "C6"
                    "B23" "CP4"
                    "B27" "P6"
                    "B31" "PO4"
                    "A04" "F1"
                    "A08" "FT7"
                    "A12" "C1"
                    "A16" "TP7"
                    "A20" "P1"
                    "A24" "P9"
                    "A28" "Iz"
                    "A32" "CPz"
                    "B04" "AF4"
                    "B08" "F4"
                    "B12" "FC6"
                    "B16" "Cz"
                    "B20" "T8"
                    "B24" "CP2"
                    "B28" "P8"
                    "B32" "O2"
                    "Status" "Status"]

    idx = findfirst(biosemi_1020, original)

    if idx == 0
        error("Channel $original is unknown")
    end

    converted = biosemi_1020[idx+size(biosemi_1020)[1]]

    debug(" $original converted to $converted")

    return converted
end

function channelNames_biosemi_1020(original::Array{String})

    converted = Array(String, size(original))

    info("Converting $(length(original)) channels")

    for i = 1:length(original)
        converted[i] = channelNames_biosemi_1020(original[i])
    end

    return converted
end
