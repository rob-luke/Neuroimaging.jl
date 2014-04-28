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

function read_bsa(fname::String; verbose::Bool=false)

    # Open file
    fid = open(fname, "r")

    # Read version
    version_line      = readline(fid)
    separator         = search(version_line, '|')
    version           = version_line[1:separator-1]
    coordinate_system = version_line[separator+1:end-1]

    # Create an empty dipole
    bsa = Dipoles(version, coordinate_system,
                    Float64[], Float64[], Float64[],
                    Float64[], Float64[], Float64[],
                    Float64[], Float64[], Float64[])

    # Read title line
    title_line = readline(fid)
    regexp = r"(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)"
    m = match(regexp, title_line)

    # Useless line
    line_line  = readline(fid)

    # Read remaining dipoles
    while ~eof(fid)
        d = readline(fid)
        dm = match(regexp, d)

        push!(bsa.xloc,  float(dm.captures[2]))
        push!(bsa.yloc,  float(dm.captures[3]))
        push!(bsa.zloc,  float(dm.captures[4]))
        push!(bsa.xori,  float(dm.captures[5]))
        push!(bsa.yori,  float(dm.captures[6]))
        push!(bsa.zori,  float(dm.captures[7]))
        push!(bsa.color, float(dm.captures[8]))
        push!(bsa.state, float(dm.captures[9]))
        push!(bsa.size,  float(dm.captures[10]))

    end

    close(fid)

    if verbose
        println("File    = $fname")
        println("Version = $version")
        println("Coords  = $coordinate_system")
        println("Dipoles = $(length(bsa.xloc))")
    end

    return bsa

end
