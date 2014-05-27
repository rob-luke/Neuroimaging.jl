Design Decisions
================

EEG Type
--------

### Data

Is of the form from smallest measurement to largest in data array.  
The number of channels is always last, as each data type explains a single recording.

  samples x channels
  samples x epochs x channels
  samples x sweeps x channels
