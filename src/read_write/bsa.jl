#######################################
#
# BSA file
#
#######################################

@doc doc"""
Read Besa's BSA (.bsa) file

### Input
* `fname`: Name or path for the BSA file

### Output
* `bsa`: Dipole object
""" ->
function read_bsa(fname::String)
    info("Reading BSA file = $fname")

    # Open file
    file = open(fname, "r")

    # Read version
    first_line        = readline(file)
    separator         = search(first_line, '|')
    version           = version_line[1:separator-1]
    coordinate_system = version_line[separator+1:end-1]

    # Create an empty dipole
    bsa = Dipole(version, coordinate_system,
                    Float64[], Float64[], Float64[], # X, Y, Z
                    Float64[], Float64[], Float64[], # Xori, Yori, Zori
                    Float64[], Float64[], Float64[]) # Color, State, Size

    # Read title line
    regexp = r"(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)"
    m = match(regexp, readline(file))

    # Read useless line
    readline(file)

    # Read remaining dipoles
    while !eof(file)
        d = readline(file)
        dm = match(regexp, d)

        push!(bsa.x,     float(dm.captures[2]))
        push!(bsa.y,     float(dm.captures[3]))
        push!(bsa.z,     float(dm.captures[4]))
        push!(bsa.xori,  float(dm.captures[5]))
        push!(bsa.yori,  float(dm.captures[6]))
        push!(bsa.zori,  float(dm.captures[7]))
        push!(bsa.color, float(dm.captures[8]))
        push!(bsa.state, float(dm.captures[9]))
        push!(bsa.size,  float(dm.captures[10]))
    end

    # Close file
    close(file)

    debug("Version = $version")
    debug("Coordinate System  = $coordinate_system")
    debug("Dipoles = $(length(bsa.x))")

    return bsa
end
