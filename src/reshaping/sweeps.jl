
#######################################
#
# Create sweeps
#
#######################################

function create_sweeps(epochs::Array, epochsPerSweep::Int)

    epochsLen = size(epochs)[1]
    epochsNum = size(epochs)[2]
    chansNum  = size(epochs)[3]

    sweepLen = epochsLen * epochsPerSweep
    sweepNum = round.(Int, floor(epochsNum / epochsPerSweep))
    sweeps = zeros(Float64, (sweepLen, sweepNum, chansNum))

    sweep = 1
    while sweep <= sweepNum

        sweepStart = (sweep-1)*(epochsPerSweep)+1
        sweepStop  = sweepStart + epochsPerSweep-1

        sweeps[:,sweep,:] = reshape(epochs[:,sweepStart:sweepStop,:], (sweepLen, 1, chansNum))

        sweep += 1
    end

    Logging.info("Generated $sweepNum sweeps of length $sweepLen for $chansNum channels")

    return sweeps
end
