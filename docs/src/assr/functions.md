# Functions

In addition to the function available for processing EEG data,
a number of functions are provided specifically for the processing of SSR data


## Import

```@docs
read_SSR
```

## Preprocessing


### Filtering

```@docs
highpass_filter(::SSR)
lowpass_filter(::SSR)
bandpass_filter(::SSR)
downsample(s::SSR, ratio::Rational)
```

## Statistics

```@docs
ftest(::SSR)
```

## Plotting

TODO: Add a summary figure as in example
