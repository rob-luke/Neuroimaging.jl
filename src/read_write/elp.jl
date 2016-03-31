#######################################
#
# elp file
#
#######################################

@doc """
Read elp file


#### Input
* `fname`: Name or path for the sfp file
* `coordinate`: Coordinate system for electrode location
* `r`: Radius for converting spherical coords

#### Output
* `elecs`: Array of electrode objects
""" ->
function read_elp(fname::AbstractString; coordinate=Talairach, r::Real=90)
    # This does not work yet, need to convert to 3d coord system

    info("Reading elp file = $fname")

    # Create an empty electrode set
    elecs = Electrode[]

    # Read file
    df = readtable(fname, header = false, separator = ' ')

    phi = df[:x2]
    theta = df[:x3]

    # Save locations
    x = r .* sin(phi*(pi/180)) .* cos(theta*(pi/180))
    y = r .* sin(phi*(pi/180)) .* sin(theta*(pi/180)) - 17.5
    z = r .* cos(phi*(pi/180))

    # Convert label to ascii and remove '
    labels = df[:x1]
    for i = 1:length(labels)
        push!(elecs, Electrode(replace(labels[i], "'", "" ), coordinate(x[i], y[i], z[i]), Dict()))
    end

    debug("Imported $(length(elecs)) electrodes")

    return elecs
end

