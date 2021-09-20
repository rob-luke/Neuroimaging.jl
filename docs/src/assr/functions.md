# Functions

In addition to the function available for processing EEG data,
a number of functions are provided specifically for the processing of SSR data


## Import

```@docs
read_SSR
```

### Filtering

```@docs
filter_highpass(::SSR)
filter_lowpass(::SSR)
filter_bandpass(::SSR)
downsample(s::SSR, ratio::Rational)
```

## Preprocessing

```@docs
extract_epochs(::SSR)
```

## Statistics

```@docs
ftest(::SSR)
```

## Plotting

```@docs
plot_spectrum(::SSR, ::Int)
```
