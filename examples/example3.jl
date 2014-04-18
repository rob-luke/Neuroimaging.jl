using JBDF
using EEGjl
using Winston

ChannelToAnalyse = 28;

dats, evtTab, trigChan, sysCodeChan = readBdf("../data/Example_40Hz_SWN_70dB_R.bdf")
bdfInfo = readBdfHeader("../data/Example_40Hz_SWN_70dB_R.bdf");
ChanName = bdfInfo["chanLabels"][ChannelToAnalyse]

singleChan = convert(Array{Float64}, vec(dats[ChannelToAnalyse,1:end]))
f = plotChannelSpectrum(convert(Array{Float64}, singleChan), 8192, ChanName)
file(f, "Eg3-1-pre.png", width=1200, height=600)

dats = filterEEG(dats)

singleChan = convert(Array{Float64}, vec(dats[ChannelToAnalyse,1:end]))
f = plotChannelSpectrum(convert(Array{Float64}, singleChan), 8192, ChanName)
file(f, "Eg3-2-filt.png", width=1200, height=600)

println("Referencing to $(bdfInfo["chanLabels"][48])")
dats = rereference(dats, 48)

singleChan = convert(Array{Float64}, vec(dats[ChannelToAnalyse,1:end]))
f = plotChannelSpectrum(convert(Array{Float64}, singleChan), 8192, ChanName)
file(f, "Eg3-3-refed.png", width=1200, height=600)

epochs = extractEpochs(dats, evtTab)
epochs = epochs[:,3:end,:]

sweeps = epochs2sweeps(epochs)

sweeps = squeeze(mean(sweeps,2),2)

singleChan = vec(sweeps[:,ChannelToAnalyse]);

t = plotChannelTime(singleChan, 8192, ChanName)
file(t, "Eg3-4-epoch.png", width=1200, height=600)

f = plotChannelSpectrum(convert(Array{Float64}, singleChan), 8192, ChanName)
file(f, "Eg3-5-epochfreq.png", width=1200, height=600)
