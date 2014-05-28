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

The following input ...
```{julia}
using EEGjl
using Winston

fname = "../data/Example-40Hz.bdf"

s = read_EEG(fname, verbose=true)

s = proc_hp(s, verbose=true)

s = proc_reference(s, "average", verbose=true)

    p = plot_timeseries(s, "Cz")
    file(p, "Eg1-RawData.png", width=1200, height=600)

    p = plot_timeseries(s)
    file(p, "Eg1-AllChannels.png", width=1200, height=800)

s = extract_epochs(s, verbose=true)

s = create_sweeps(s, epochsPerSweep=32, verbose=true)

s = ftest(s, 40.0391, verbose=true)

    p = plot_spectrum(s, "T8", targetFreq=40.0391)
    file(p, "Eg1-SweepSpectrum-52.png", width=1200, height=800)

```

outputs...


```{julia}

Converting EEG channel names
Imported 64 EEG channels
Highpass filtering 64 channels
  Pass band > 2 Hz
  Filtering... 100%|##################################################| Time: 0:00:15
Re referencing 64 channels to channel average
Re referencing 64 channels to the mean of 64 channels
  Rerefing...  100%|##################################################| Time: 0:00:04
Generating epochs for 64 channels
  Epoch length is 8388
  Number of epochs is 290
  Epoching...  100%|##################################################| Time: 0:00:02
Generating 9 sweeps
  From 290 epochs of length 8388
  Creating 9 sweeps of length 268416
  Sweeps...    100%|##################################################| Time: 0:00:01
Calculating F statistic on 64 channels
  F-test...    100%|##################################################| Time: 0:00:30

```


![timeseries](/examples/Eg1-RawData.png)
![timeseries](/examples/Eg1-AllChannels.png)
![timeseries](/examples/Eg1-SweepSpectrum-T8.png)
