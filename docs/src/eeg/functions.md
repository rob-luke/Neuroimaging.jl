# Functions

In addition to the function available for processing EEG data,
a number of functions are provided specifically for the processing of SSR data


## Import

```@docs
read_EEG
```

## Preprocessing


### Filtering

```@docs
highpass_filter(::EEG)
lowpass_filter(::EEG)
```

## Statistics

```@docs
ftest(::SSR)
save_results(::EEG)
```

## Plotting

```@docs
plot_timeseries(::EEG)
```


