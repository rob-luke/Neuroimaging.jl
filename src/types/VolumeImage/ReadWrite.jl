function read_VolumeImage(fname::String)

    Logging.info("Creating volume image from file $fname")

    if contains(fname, ".dat")
        x, y, z, s, t = read_dat(fname)
        method = "CLARA"
        header = Dict()
        units = "nAm/cm^3"
        x = x/1000
        y = y/1000
        z = z/1000
        t = t/1000
    else
        Logging.warn("Unknown file type")
    end

    header["FileName"] = fname

    coord_system = "?"

    VolumeImage(s, units, x, y, z, t, method, header, coord_system)
end


