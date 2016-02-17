#######################################
#
# elp file
#
#######################################

@doc """
Read elp file

(Not yet working, need to convert to 3d coord system)

#### Input
* `fname`: Name or path for the sfp file

#### Output
* `elec`: Electrodes object
""" ->
function read_elp(fname::AbstractString)
    # This does not work yet, need to convert to 3d coord system

    info("Reading elp file = $fname")

    # Create an empty electrode set
    elec = Electrodes("unknown", "EEG", AbstractString[], Float64[], Float64[], Float64[])

    # Read file
    df = readtable(fname, header = false, separator = ' ')

    phi = df[:x2]
    theta = df[:x3]
    r = 90.0

    # Save locations
    elec.x = r .* sin(phi*(pi/180)) .* cos(theta*(pi/180))
    elec.y = r .* sin(phi*(pi/180)) .* sin(theta*(pi/180)) - 17.5
    elec.z = r .* cos(phi*(pi/180))

    # Convert label to ascii and remove '
    labels = df[:x1]
    for i = 1:length(labels)
        push!(elec.label, replace(labels[i], "'", "" ))
    end

    debug("Imported $(length(elec.x)) locations")
    debug("Imported $(length(elec.label)) labels")

    return elec
end

