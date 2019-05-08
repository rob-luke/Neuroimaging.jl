#######################################
#
# sfp file
#
#######################################

"""
Read sfp file containing sensor locations

#### Input
* `fname`: Path for the sfp file

#### Output
* `elec`: Electrodes object
"""
function read_sfp(fname::AbstractString; coordinate=Talairach)

    @info("Reading dat file = $fname")

    # Create an empty electrode set
    elecs = Electrode[]

    # Read file and match to expected file format
    file = read(fname, String)
    regexp = r"(\S+)\s+(\S+)\s+(\S+)\s+(\S+)"
    m = matchall(regexp, file)

    # Convert label to ascii and remove '
    for idx = 1:length(m)
        local_matches = match(regexp, m[idx])
        push!(elecs, Electrode(replace(local_matches[1], "'", "" ), coordinate(float(local_matches[2]), float(local_matches[3]), float(local_matches[4])), Dict()))
    end

    @debug("Imported $(length(elecs)) electrodes")

    return elecs
end
