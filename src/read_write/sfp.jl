#######################################
#
# sfp file
#
#######################################

@doc """
Read sfp file

#### Input
* `fname`: Name or path for the sfp file

#### Output
* `elec`: Electrodes object
""" ->
function read_sfp(fname::AbstractString)
    info("Reading dat file = $fname")

    # Create an empty electrode set
    elec = Electrodes("Cartesian", "EEG", AbstractString[], Float64[], Float64[], Float64[])

    # Read file
    df = readtable(fname, header = false, separator = ' ')

    # Save locations
    elec.x = df[:x2]
    elec.y = df[:x3]
    elec.z = df[:x4]

    # Convert label to ascii and remove '
    labels = df[:x1]
    for i in eachindex(labels)
        push!(elec.label, replace(labels[i], "'", "" ))
    end

    debug("Imported $(length(elec.x)) locations")
    debug("Imported $(length(elec.label)) labels")

    return elec
end
