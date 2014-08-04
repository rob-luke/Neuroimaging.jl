

function write_dat(fname::String,
                   X::AbstractVector, Y::AbstractVector, Z::AbstractVector,
                   S::Array{Float64,4}, T::AbstractVector;
                   data_file::String="NA", condition::String="NA", method::String="NA", regularization::String="NA",
                   units::String="NA")

    if size(S,1) != length(X); warn("Data and x sizes do not match"); end
    if size(S,2) != length(Y); warn("Data and y sizes do not match"); end
    if size(S,3) != length(Z); warn("Data and z sizes do not match"); end
    if size(S,4) != length(T); warn("Data and t sizes do not match"); end

    info("Saving dat to $fname")

    fid = open(fname, "w")

    @printf(fid, "BESA_SA_IMAGE:2.0\n")
    @printf(fid, "\n")
    @printf(fid, "Data file:          %s\n", data_file)
    @printf(fid, "Condition:          %s\n", condition)
    @printf(fid, "Method:             %s\n", method)
    @printf(fid, "Regularization:     %s\n", regularization)
    @printf(fid, "  %s\n",                   units)

    @printf(fid, "\n")
    @printf(fid, "Grid dimensions ([min] [max] [nr of locations]):\n")
    @printf(fid, "X:  %2.6f %2.6f %d\n", minimum(X), maximum(X), length(X))
    @printf(fid, "Y:  %2.6f %2.6f %d\n", minimum(Y), maximum(Y), length(Y))
    @printf(fid, "Z:  %2.6f %2.6f %d\n", minimum(Z), maximum(Z), length(Z))
    @printf(fid, "==============================================================================================\n")

    for t = 1:size(S, 4)
        @printf(fid, "Sample %d, %1.2f ms\n", t-1, T[t])
        for z = 1:size(S, 3)
            @printf(fid, "Z: %d\n", z-1)
            for y = 1:size(S,2)
                for x = 1:size(S,1)
                    @printf(fid, "%2.10f ", S[x,y,z,t])
                end
                @printf(fid, "\n")
            end
            @printf(fid, "\n")
        end
    end
    debug("File successfully written")

    close(fid)
end


function write_avr(fname::String, data::Array, chanNames::Array, fs::Int)

    info("Saving avr to $fname")

    fid = open(fname, "w")

    @printf(fid, "Npts= %d   TSB= %2.6f DI= %2.6f SB= %2.3f SC= %3.1f Nchan= %d\n", size(data,1), 1000/fs, 1000/fs,
            1.0, 200.0, size(data,2))

    @printf(fid, "%s", chanNames[1])
    for c = 2:length(chanNames)
        @printf(fid, " ")
        @printf(fid, "%s", chanNames[c])
    end
    @printf(fid, "\n")

    for c = 1:size(data,2)
        @printf(fid, "%2.6f", data[1,c])
        for p = 2:size(data,1)
            @printf(fid, " ")
            @printf(fid, "%2.6f", data[p,c])
        end
        @printf(fid, " ")
        @printf(fid, "\n")
    end

    close(fid)
end
