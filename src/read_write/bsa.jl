#######################################
#
# BSA file
#
#######################################

@doc """
Read Besa's BSA (.bsa) file

#### Input
* `fname`: Name or path for the BSA file

#### Output
* `bsa`: Dipole object
""" ->
function read_bsa(fname::AbstractString)
    Logging.info("Reading BSA file = $fname")

    # Open file
    file = open(fname, "r")

    # Read version
    first_line        = readline(file)
    separator         = search(first_line, '|')
    version           = first_line[1:separator-1]
    coordinate_system = first_line[separator+1:end-1]

    # Read title line
    regexp = r"(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)"
    m = match(regexp, readline(file))

    # Read useless line
    readline(file)

    # Read dipoles
    dips = EEG.Dipole[]
    while !eof(file)
        dm = match(regexp, readline(file))

        dip = Dipole(coordinate_system, float(dm.captures[2])/1000, float(dm.captures[3])/1000, float(dm.captures[4])/1000,
                                        float(dm.captures[5]), float(dm.captures[6]), float(dm.captures[7]),
                                        float(dm.captures[8]), float(dm.captures[9]), float(dm.captures[10]))

        push!(dips, dip)
    end

    # Close file
    close(file)

    debug("Version = $version")
    debug("Coordinate System  = $coordinate_system")
    debug("Dipoles = $(length(dips))")

    return dips
end
