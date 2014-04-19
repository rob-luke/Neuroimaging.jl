using JBDF
using EEGjl
using Winston

ChannelToAnalyse = 28;

dats, evtTab, trigChan, sysCodeChan = readBdf("../data/Example_40Hz_SWN_70dB_R.bdf")
bdfInfo = readBdfHeader("../data/Example_40Hz_SWN_70dB_R.bdf");
ChanName = bdfInfo["chanLabels"][ChannelToAnalyse]

singleChan = convert(Array{Float64}, vec(dats[ChannelToAnalyse,1:end]))
f = plot_spectrum(singleChan, 8192, titletext=ChanName)
file(f, "Eg3-1-pre.png", width=1200, height=600)

dats = proc_hp(dats)

singleChan = convert(Array{Float64}, vec(dats[ChannelToAnalyse,1:end]))
f = plot_spectrum(singleChan, 8192, titletext=ChanName)
file(f, "Eg3-2-filt.png", width=1200, height=600)

println("Referencing to $(bdfInfo["chanLabels"][48])")
dats = proc_rereference(dats, 48)

singleChan = convert(Array{Float64}, vec(dats[ChannelToAnalyse,1:end]))
f = plot_spectrum(singleChan, 8192, titletext=ChanName)
file(f, "Eg3-3-refed.png", width=1200, height=600)

epochs = proc_epochs(dats, evtTab)
epochs = epochs[:,3:end,:]

sweeps = proc_sweeps(epochs)

sweeps = squeeze(mean(sweeps,2),2)

singleChan = vec(sweeps[:,ChannelToAnalyse]);

t = plot_timeseries(singleChan, 8192, titletext=ChanName)
file(t, "Eg3-4-epoch.png", width=1200, height=600)

f = plot_spectrum(singleChan, 8192, titletext=ChanName)
file(f, "Eg3-5-epochfreq.png", width=1200, height=600)
