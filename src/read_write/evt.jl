#######################################
#
# evt file
#
#######################################

@doc """
Read *.evt file and convert to form for EEG.jl
""" ->
function read_evt(fname::String, fs::Number; kwargs...)
    Logging.info("Reading evt file: $fname")

    d = readdlm(fname)

    if size(d,2) > 3
        warn("EVT file has too many columns")
    end

    d = [d[1,1] => d[2:end, 1], d[1,2] => d[2:end, 2], d[1,3] => d[2:end, 3]]

    if haskey(d, "Tmu")
        d["Index"] = round(float(d["Tmu"]) * (1 / 1000000) * float(fs)) + 1
    elseif haskey(d, "Tsec")
        d["Index"] = round(float(d["Tsec"])  * float(fs)) + 1
    else
        warn("Unknown time scale in evt file")
    end

    d["Duration"] = ones(length(d["Code"]))

    Logging.info("Imported $(length(d["Code"])) events")

    return ["Code" => d["Code"] + 252, "Index" => d["Index"], "Duration" => d["Duration"]]
end
