# Examples

## Reading data

The following code reads a steady state response recording stored in biosemi data format.
The function extracts standard steady state parameters from the file name.

```@example fileread
using DisplayAs # hide
using Neuroimaging, DataDeps, Plots
data_path = joinpath(
    datadep"ExampleSSR",
    "Neuroimaging.jl-example-data-master",
    "neuroimaingSSR.bdf",
)

s = read_SSR(data_path)
```

We can inform the software of additional information such as the stimulus modulation rate.

```@example fileread
s.modulationrate = 40.0391u"Hz"
```

## Get info

What are the channel names?

```@example fileread
println(channelnames(s))
```

And the sample rate?

```@example fileread
samplingrate(s)
```

Trigger info?
This needs to be changed so it abstracts away from the type.
It should be a function as in the two examples above.

```@example fileread
s.triggers
```

## Filter data

```@example fileread
s = highpass_filter(s)
```

## Rereference data

```@example fileread
s = rereference(s, "Cz")
remove_channel!(s, "Cz")
```

## Plot data

```@example fileread
plot_timeseries(s, channels="TP7")
current() |> DisplayAs.PNG # hide
```


## Extract SSR at frequency of interest

```@example fileread

s = extract_epochs(s)

s = create_sweeps(s, epochsPerSweep = 8)

s = ftest(s)

s.processing["statistics"]

```

## Demonstrate no false postiive at other freqs

```@example fileread

s = ftest(s, freq_of_interest=32.0391)

s.processing["statistics"]
```