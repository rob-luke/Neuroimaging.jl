using JBDF
using EEGjl
using Winston


# Import data
fname = "../data/Example-40Hz.bdf"
dats, evtTab, trigChan, sysCodeChan = readBdf(fname)
bdfInfo = readBdfHeader(fname)
bdfInfo["chanLabels"] = channelNames_biosemi_1020(bdfInfo["chanLabels"], verbose=false)

# What channel to look at
ChannelToAnalyse = 52;
ChanName = bdfInfo["chanLabels"][ChannelToAnalyse]

dats = proc_hp(dats, verbose=true)

dats = proc_reference(dats, "Cz", bdfInfo["chanLabels"], verbose=true)

t = plot_timeseries_multichannel(dats[:, 3*8192:end], 8192, chanLabels=bdfInfo["chanLabels"])
file(t, "Eg1-AllChannels.png", width=1200, height=600)

singleChan = convert(Array{Float64}, vec(dats[ChannelToAnalyse,8192*2:end]))
f = plot_timeseries(singleChan, 8192, titletext=ChanName)
file(f, "Eg1-RawData.png", width=1200, height=600)

epochs = proc_epochs(dats, evtTab, verbose=true)
epochs = epochs[:,3:end,:]

epochs = proc_epoch_rejection(epochs)

sweeps = proc_sweeps(epochs, verbose=true, epochsPerSweep=32)

meanSweeps = squeeze(mean(sweeps,2),2)

while ChannelToAnalyse <= 64

    if ChannelToAnalyse == 48
        ChannelToAnalyse += 1
    end

    ChanName = bdfInfo["chanLabels"][ChannelToAnalyse]
    fResult, s, n = proc_ftest(sweeps, 40.0391, 8192, ChannelToAnalyse)
    title = "Channel $(ChanName). SNR = $(round(fResult,2)) dB"

    singleChan = convert(Array{Float64}, vec(meanSweeps[:,ChannelToAnalyse]))

    f = plot_spectrum(singleChan, 8192, titletext=title, dBPlot=true,
        signal_level=s, noise_level=n, targetFreq=40.0391)
    file(f, "Eg1-SweepSpectrum-$(ChannelToAnalyse).pdf", width=1200, height=600)

    ChannelToAnalyse += 99
end
