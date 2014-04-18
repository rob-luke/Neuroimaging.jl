using JBDF
using EEGjl
using Winston

dats, evtTab, trigChan, sysCodeChan = readBdf("../data/Example_40Hz_SWN_70dB_R.bdf")

bdfInfo = readBdfHeader("../data/Example_40Hz_SWN_70dB_R.bdf");
bdfInfo["chanLabels"];
singleChan = vec(dats[1,1:end]);
time = linspace( 0, length(singleChan)/8192, length(singleChan));

t = plotChannelTime(singleChan, 8192, "Test Channel")
file(t, "data.png", width=1200, height=600)

f = plotChannelSpectrum(convert(Array{Float64}, singleChan), 8192, "Test Channel")
file(f, "datafreq.png", width=1200, height=600)



