# EEG

[![Build Status](https://travis-ci.org/codles/EEG.jl.svg?branch=master)](https://travis-ci.org/codles/EEG.jl)
[![Coverage Status](https://img.shields.io/coveralls/codles/EEG.jl.svg)](https://coveralls.io/r/codles/EEG.jl?branch=master)

Process EEG files in Julia.  
**This package is not tested. Use at your own risk**  


This package includes low level processing functions (filtering, referencing, statistics etc).  
It also includes types for various EEG measurments (ASSR, ABR etc) and wrapper functions to process these files using the lower level functions.


## Functions

Currently there are function for the following processes on raw data and ASSR types

#### Preprocessing
- filtering  
- re-referencing
- epoch and sweep extraction
- epoch rejection based on peak to peak amplitudes

#### Statistics
- ftest

#### File IO
- *.dat

## Installation

Requires:
- BDF
- DSP
- Winston
- DataFrames
- ProgressMeter
- Logging
  
Pkg.clone("git://github.com/codles/EEG.jl.git")

