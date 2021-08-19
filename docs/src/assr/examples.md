# Examples

## Reading data

The following code reads a steady state response recording stored in biosemi data fromat.
The function extracts standard steady state parameters from the file name.

```@example fileread
using EEG, DataDeps
register(
    DataDep(
        "BioSemiTestFiles",
        "Manafacturer provided example files",
        ["https://www.biosemi.com/download/BDFtestfiles.zip"];
        post_fetch_method = [file -> run(`unzip $file`)],
    ),
)
```

```@example fileread
using EEG, DataDeps
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

## Old static example

```julia
using EEG

s = read_SSR("file.bdf")
s = highpass_filter(s)
s = rereference(s, "Cz")
s = trim_channel(s, 8192*80, start = 8192*50)

plot_timeseries(s, channels="P6")
plot_timeseries(s)
```

![Single Channel](https://cloud.githubusercontent.com/assets/748691/17362166/210e53f4-5974-11e6-8df0-c2723c65ba52.png)
![Multi Channel](https://cloud.githubusercontent.com/assets/748691/17362167/210f9c28-5974-11e6-8a05-62fa399d32d1.png)
