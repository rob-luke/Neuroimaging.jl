# Examples

## Reading data

The following code reads a steady state response recording stored in biosemi data format.
The function extracts standard steady state parameters from the file name.

```@example fileread
using DisplayAs # hide
using Neuroimaging, DataDeps, Plots
data_path = joinpath(datadep"BioSemiTestFiles", "Newtest17-2048.bdf")
s = read_SSR(data_path)
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
s = rereference(s, "A9")
```

## Rereference data

```@example fileread
plot_timeseries(s, channels="A6")
current() |> DisplayAs.PNG # hide
```
