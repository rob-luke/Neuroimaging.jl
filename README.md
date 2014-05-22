# EEGjl

Process EEG files in Julia.


## Installation

Package is not ready for distribution yet.

Requires:
- JBDF
- Winston
- DSP
- DataFrames
- ProgressMeter
  


## Usage

Import raw data using [JBDF](https://github.com/sam81/JBDF.jl).

```
s = read_EEG("../data/example.bdf", verbose=true)

>>>> Imported 64 EEG channels
```

Remove DC offset and re reference data to cz

```
s = proc_hp(s, verbose=true)

>>> Highpass filtering 64 channels
>>>   Pass band > 2 Hz
>>>   Filtering... 100%|##################################################| Time: 0:00:26
  
s = proc_reference(s, "average", verbose=true)

>>> Re referencing 64 channels to channel average
>>> Re referencing 64 channels to the mean of 64 channels
>>>   Rerefing...  100%|##################################################| Time: 0:00:06

p = plot_timeseries(s, "Cz")

p = plot_timeseries(s)

```

![timeseries](/examples/Eg1-RawData.png)
![timeseries](/examples/Eg1-AllChannels.png)

Generate epochs, combine to average sweeps and plot the spectrum

```
epochs = proc_epochs(dats, evtTab, verbose=true)

>>>Generating epochs for 64 channels
>>>  Epoch length is 8388
>>>  Number of epochs is 302
>>>  Number of channels is 64
>>>  Epoching...100%|##################################################| Time: 0:00:05

epochs = proc_epoch_rejection(epochs)


sweeps = proc_sweeps(epochs, verbose=true)

>>>Generating 75.0 sweeps
>>>  From 300 epochs of length 8388
>>>  Creating 75.0 sweeps of length 33552
>>>  Sweeps...  100%|##################################################| Time: 0:00:03


sweeps = squeeze(mean(sweeps,2),2)
f = plot_spectrum(singleChan, 8192, titletext=ChanName)
```

![timeseries](/examples/Eg1-SweepSpectrum-52.png)
