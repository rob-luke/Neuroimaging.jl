#######################################
#
# BSA file
#
#######################################

"""
Read Besa's BSA (.bsa) file

#### Input
* `fname`: Name or path for the BSA file

#### Output
* `bsa`: Dipole object
"""
function read_bsa(fname::AbstractString)
    @info("Reading BSA file = $fname")

    # Open file
    file = open(fname, "r")

    # Read version
    first_line        = readline(file)
    separator         = something(findfirst(isequal('|'), first_line), 0)
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

        dip = Dipole(coordinate_system, 1u"m" * parse(Float64, dm.captures[2])/1000, 1u"m" * parse(Float64, dm.captures[3])/1000, 1u"m" * parse(Float64, dm.captures[4])/1000,
                                                parse(Float64, dm.captures[5]), parse(Float64, dm.captures[6]), parse(Float64, dm.captures[7]),
                                                parse(Float64, dm.captures[8]), parse(Float64, dm.captures[9]), parse(Float64, dm.captures[10]))

        push!(dips, dip)
    end

    # Close file
    close(file)

    @debug("Version = $version")
    @debug("Coordinate System  = $coordinate_system")
    @debug("Dipoles = $(length(dips))")

    return dips
end
