module EEGjl

export
    plotChannelTime,
    plotChannelSpectrum,
    extractEpochs,
    filterEEG,
    epochs2sweeps,
    rereference,
    plotEpochSpectrum

include("plot.jl")
include("processing.jl")

end
