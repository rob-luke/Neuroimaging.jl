using Winston
using DataFrames

type BSA
    version::String
    coord_system::String
    xloc::Array
    yloc::Array
    zloc::Array
end

function read_bsa(fname::String; verbose::Bool=true)

    # Open file
    fid = open(fname, "r")

    # Read version
    version_line      = readline(fid)
    separator         = search(version_line, '|')
    version           = version_line[1:separator-1]
    coordinate_system = version_line[separator+1:end-1]

    # Read title line
    title_line = readline(fid)
    regexp = r"(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)"
    m = match(regexp, title_line)

    # Create variables to fill
    xloc = Float64[]
    yloc = Float64[]
    zloc = Float64[]

    line_line  = readline(fid)

    if verbose
        println("File    = $fname")
        println("Version = $version")
        println("Coords  = $coordinate_system")
    end

    while ~eof(fid)
        d = readline(fid)
        dm = match(regexp, d)

        push!(xloc, float(dm.captures[2]))
        push!(yloc, float(dm.captures[3]))
        push!(zloc, float(dm.captures[4]))

    end

    close(fid)

    bsa = BSA(version, coordinate_system, xloc, yloc, zloc)

    return bsa

end
