using JBDF
using EEGjl
using Winston

dats, evtTab, trigChan, sysCodeChan = readBdf("../data/Example_40Hz_SWN_70dB_R.bdf")
singleChan = convert(Array{Float64}, vec(dats[1,1:end]))

epochs = extractEpochs(dats, evtTab)

epochs = mean(epochs,2)

singleChan = vec(epochs[1,1,1:end]);
time = linspace( 0, length(singleChan)/8192, length(singleChan));

t = plotChannelTime(singleChan, 8192, "Test Channel")
file(t, "epoch.png", width=1200, height=600)

f = plotChannelSpectrum(convert(Array{Float64}, singleChan), 8192, "Test Channel")
file(f, "epochfreq.png", width=1200, height=600)

