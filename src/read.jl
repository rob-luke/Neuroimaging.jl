using Winston
using DataFrames

type Dipoles
    version::String
    coord_system::String
    xloc::Array
    yloc::Array
    zloc::Array
    xori::Array
    yori::Array
    zori::Array
    color::Array
    state::Array
    size::Array
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
    xloc  = Float64[]
    yloc  = Float64[]
    zloc  = Float64[]
    xori  = Float64[]
    yori  = Float64[]
    zori  = Float64[]
    color = Float64[]
    state = Float64[]
    size  = Float64[]


    line_line  = readline(fid)

    if verbose
        println("File    = $fname")
        println("Version = $version")
        println("Coords  = $coordinate_system")
        println("$title_line")
    end

    while ~eof(fid)
        d = readline(fid)
        dm = match(regexp, d)

        push!(xloc,  float (dm.captures[2]))
        push!(yloc,  float (dm.captures[3]))
        push!(zloc,  float (dm.captures[4]))
        push!(xori,  float (dm.captures[5]))
        push!(yori,  float (dm.captures[6]))
        push!(zori,  float (dm.captures[7]))
        push!(color, float (dm.captures[8]))
        push!(state, float (dm.captures[9]))
        push!(size,  float (dm.captures[10]))

    end

    close(fid)

    bsa = Dipoles(version, coordinate_system, xloc, yloc, zloc, xori, yori, zori, color, state, size)

    return bsa

end
