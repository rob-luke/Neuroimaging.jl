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
```

## Statistics

```@docs
ftest(::SSR)
save_results(::SSR)
```

## Plotting

```@docs
plot_timeseries(::SSR)
```


