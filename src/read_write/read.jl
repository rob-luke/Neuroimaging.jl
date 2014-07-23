# Read files
#
# read_bsa
# read_dat
# read_sfp
#


using DataFrames


#######################################
#
# Read BSA file
#
#######################################

function read_bsa(fname::String)

    # Open file
    fid = open(fname, "r")

    # Read version
    version_line      = readline(fid)
    separator         = search(version_line, '|')
    version           = version_line[1:separator-1]
    coordinate_system = version_line[separator+1:end-1]

    # Create an empty dipole
    bsa = Dipole(version, coordinate_system,
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

    info("BSA file imported: $fname")
    debug("Version = $version")
    debug("Coords  = $coordinate_system")
    debug("Dipoles = $(length(bsa.xloc))")

    return bsa
end


#######################################
#
# Read dat file
#
#######################################

function read_dat(fname::String)

    # File specs taken from https://github.com/fieldtrip/fieldtrip/blob/1cabb512c46cc70e5b734776f20cdc3c181243bd/external/besa/readBESAimage.m


    info("Reading dat file = $fname")

    # Open file
    fid = open(fname, "r")

    # Ensure we are reading version 2
    version = readline(fid)
    version = match(r"(\S+):(\d.\d)", version)
    version = float(version.captures[2])
    if version != 2
        warning("Unknown dat file version!!")
        return
    end

    # Header info
    empty          = readline(fid)
    data_file      = readline(fid)
    condition      = readline(fid)
    typeline       = readline(fid)

    # Types of data that can be stored
    if search(typeline, "Method") != 0:-1  # TODO: change to imatch
        debug("File type is Method")
        image_type = typeline[21:end]
        image_mode = "Time"
        regularization = readline(fid)[21:end-1]
        #=Latency=#  # TODO: Fix for latencies. See fieldtrip
        #=Units=#
        units          = readline(fid)[3:end-1]
        debug("Regularisation = $regularization")
        debug("Units = $units")
    elseif search(typeline, "MSBF") != 0:-1
        warning("Type not implemented yet")
    elseif search(typeline, "MSPS") != 0:-1
        warning("Type not implemented yet")
    elseif search(typeline, "Sens") != 0:-1
        warning("Type not implemented yet")
    else
        warning("Unknown type")
    end

    empty       = readline(fid)
    description = readline(fid)

    # Read in the dimensions
    regexp = r"[X-Z]:\s+(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+(-?\d+)"
    X = match(regexp, readline(fid))
    X = linspace(float(X.captures[1]), float(X.captures[2]), int(X.captures[3]))
    Y = match(regexp, readline(fid))
    Y = linspace(float(Y.captures[1]), float(Y.captures[2]), int(Y.captures[3]))
    Z = match(regexp, readline(fid))
    Z = linspace(float(Z.captures[1]), float(Z.captures[2]), int(Z.captures[3]))

    empty       = readline(fid)

    # Variables to fill
    t = 1
    complete_data = Array(Float64, (length(X), length(Y), length(Z), t))
    sample_times  = Float64[]

    description = readline(fid)
    if search(description, "Sample") != 0:-1

        s = match(r"Sample \d+, (\d+.\d+) ms", description)
        push!(sample_times, float(s.captures[1]))

        file_still_going = true
        while file_still_going

            for z = 1:length(Z)
                readline(fid)           # Z: z

                for y = 1:length(Y)
                    d = readline(fid)       # values

                    for x = 1:length(X)
                        complete_data[x, y, z, t] = float(d[(x-1)*13+1:(x-1)*13+11])
                    end
                end

                readline(fid)           # blank or dashed

            end

            if eof(fid)
                file_still_going = false
            else

                t += 1

                s = readline(fid)               # Sample n, t.tt ms
                s = match(r"Sample \d+, (\d+.\d+) ms", s)
                push!(sample_times, float(s.captures[1]))

                # There is no nice way to grow a multidimensional array
                temp = complete_data
                complete_data = Array(Float64, (length(X), length(Y), length(Z), t))
                complete_data[:,:,:,1:t-1] = temp

            end

        end
    else
        warning("Unsported file")
    end

    close(fid)

    return X, Y, Z, complete_data, sample_times
end


#######################################
#
# Read sfp file
#
#######################################

function read_sfp(fname::String)

    info("Reading dat file = $fname")

    # Create an empty electrode set
    elec = Electrodes("unknown", "EEG", String[], Float64[], Float64[], Float64[])

    # Read file
    df = readtable(fname, header = false, separator = ' ')

    # Save locations
    elec.xloc = df[:x2]
    elec.yloc = df[:x3]
    elec.zloc = df[:x4]

    # Convert label to ascii and remove '
    labels = df[:x1]
    for i = 1:length(labels)
        push!(elec.label, replace(labels[i], "'", "" ))
    end

    debug("Imported $(length(elec.xloc)) locations")
    debug("Imported $(length(elec.label)) labels")

    return elec
end


#######################################
#
# Read elp file
#
#######################################

function read_elp(fname::String)
    # Read elp file
    #
    # This does not work yet, need to convert to 3d coord system

    error("Reading ELPs has not been validated")

    info("Reading elp file = $fname")

    # Create an empty electrode set
    elec = Electrodes("unknown", "EEG", String[], Float64[], Float64[], Float64[])

    # Read file
    df = readtable(fname, header = false, separator = ' ')

    # Save locations
    elec.xloc = df[:x2]  #TODO: Fix elp locations to 3d
    elec.yloc = df[:x3]

    # Convert label to ascii and remove '
    labels = df[:x1]
    for i = 1:length(labels)
        push!(elec.label, replace(labels[i], "'", "" ))
    end

    debug("Imported $(length(elec.xloc)) locations")
    debug("Imported $(length(elec.label)) labels")

    return elec
end
