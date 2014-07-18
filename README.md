# EEG

[![Build Status](https://travis-ci.org/codles/EEG.jl.svg?branch=master)](https://travis-ci.org/codles/EEG.jl)
[![Coverage Status](https://img.shields.io/coveralls/codles/EEG.jl.svg)](https://coveralls.io/r/codles/EEG.jl?branch=master)

Process EEG files in Julia.  
**This package is not ready for distribution yet.**
Pkg.clone("git://github.com/codles/EEG.jl.git")

This package includes low level processing functions (filtering, referencing, statistics etc).  
It also includes a type for each type of EEG recording (ASSR, ABR etc) and wrapper functions to process these files using the lower level functions.


## Functions

Currently there are function for the following processes on raw data and ASSR types

#### Preprocessing
- filtering  
- re-referencing
- epoch and sweep extraction
- epoch rejection based on peak to peak amplitudes

#### Statistics
- ftest


## Installation

Requires:
- BDF
- DSP
- Winston
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

s = read_EEG(fname, verbose=true)

s = proc_hp(s, cutOff=2, verbose=true)

    p = plot_filter_response(s.processing["filter1"], 8192)
    file(p, "Eg1-Filter.png", width=1200, height=800)

s = proc_reference(s, "average", verbose=true)

    p = plot_timeseries(s, "Cz")
    file(p, "Eg1-RawData.png", width=1200, height=600)

    p = plot_timeseries(s)
    file(p, "Eg1-AllChannels.png", width=1200, height=800)

s = extract_epochs(s, verbose=true)

s = create_sweeps(s, epochsPerSweep=32, verbose=true)

s = ftest(s, 40.0391, verbose=true)
s = ftest(s, 41.0391, verbose=true)

    p = plot_spectrum(s, "T8", targetFreq=40.0391)
    file(p, "Eg1-SweepSpectrum-T8.png", width=1200, height=800)

s = save_results(s, "test.csv", verbose=true)
```

outputs...


```
Imported 64 ASSR channels
  Converting names from BIOSEMI to 10-20

Highpass filtering 64 channels
  Pass band > 2 Hz
  Filtering... 100%|##################################################| Time: 0:00:14

Re referencing 64 channels to channel average
Re referencing 64 channels to the mean of 64 channels
  Rerefing...  100%|##################################################| Time: 0:00:03

Generating epochs for 64 channels
  Epoch length is 8388
  Number of epochs is 290
  Epoching...  100%|##################################################| Time: 0:00:02

Generating 9 sweeps
  From 290 epochs of length 8388
  Creating 9 sweeps of length 268416
  Sweeps...    100%|##################################################| Time: 0:00:02

Calculating F statistic on 64 channels at 40.0391 Hz
  F-test...    100%|##################################################| Time: 0:01:16

Calculating F statistic on 64 channels at 41.0391 Hz
  F-test...    100%|##################################################| Time: 0:01:18

```


![timeseries](/examples/Eg1-RawData.png)
![timeseries](/examples/Eg1-AllChannels.png)
![timeseries](/examples/Eg1-SweepSpectrum-T8.png)
