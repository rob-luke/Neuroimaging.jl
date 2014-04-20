# EEGjl

Process EEG files in Julia.


## Installation

Package is not ready for distribution yet.

Requires:
- Winston
- DSP
- DataFrames
- ProgressMeter
  


## Usage

Import raw data using [JBDF](https://github.com/sam81/JBDF.jl).

```
dats, evtTab, trigChan, sysCodeChan = readBdf("../data/example.bdf")
bdfInfo = readBdfHeader("../data/example.bdf")
```

Remove DC offset and re reference data to cz

```
dats = proc_hp(dats, verbose=true)

>>>Highpass filtering 64 channels
>>>  Pass band > 2 Hz = 0.00048828125
>>>  Filtering...100%|##################################################| Time: 0:00:28
  
  
dats = proc_rereference(dats, 48, verbose=true)

>>>Re referencing 64 channels
>>>  Rerefing... 100%|##################################################| Time: 0:00:09


f = plot_timeseries(singleChan, 8192, titletext=ChanName)
```

![timeseries](/examples/Eg1-RawData.png)

Generate epochs, combine to average sweeps and plot the spectrum

```
epochs = proc_epochs(dats, evtTab, verbose=true)

>>>Generating epochs for 64 channels
>>>  Epoch length is 8388
>>>  Number of epochs is 302
>>>  Number of channels is 64
>>>  Epoching...100%|##################################################| Time: 0:00:05


sweeps = proc_sweeps(epochs, verbose=true)
>>>Generating 75.0 sweeps
>>>  From 300 epochs of length 8388
>>>  Creating 75.0 sweeps of length 33552
>>>  Sweeps...  100%|##################################################| Time: 0:00:03


sweeps = squeeze(mean(sweeps,2),2)
f = plot_spectrum(singleChan, 8192, titletext=ChanName)
```

![timeseries](/examples/Eg1-SweepSpectrum.png)
