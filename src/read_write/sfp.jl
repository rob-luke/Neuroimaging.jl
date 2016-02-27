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
function read_sfp(fname::AbstractString; coordinate=Talairach)
    info("Reading dat file = $fname")

    # Create an empty electrode set
    elecs = Electrode[]

    # Read file
    df = readtable(fname, header = false, separator = ' ')

    # Save locations
    x = df[:x2]
    y = df[:x3]
    z = df[:x4]

    # Convert label to ascii and remove '
    labels = df[:x1]
    for i = 1:length(labels)
        push!(elecs, Electrode(replace(labels[i], "'", "" ), coordinate(x[i], y[i], z[i]), Dict()))
    end

    debug("Imported $(length(elecs)) electrodes")

    return elecs
end
