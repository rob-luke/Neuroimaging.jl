# Example

This tutorial demonstrates how to analyse an EEG measurement with Neuroimaging.jl

Note: this example demonstrates the existing capabilities of the package.
General improvements are planned to this package. But before changes are made,
the existing features and functions will be documented. This will help to highlight
was has already been implemented, and where improvements need to be made.


## Read data

First we read the measurement data which is stored in biosemi data format.

```@example fileread
using DisplayAs # hide
using Neuroimaging, DataDeps, Unitful
data_path = joinpath(
    datadep"ExampleSSR",
    "Neuroimaging.jl-example-data-master",
    "neuroimaingSSR.bdf",
)

s = read_EEG(data_path)
```


## Get info

Now that the data has been imported, we can query it to ensure the
requisite information is available. First we query the file channel names.
Note that we call the function `channelnames`, and do not access properties of the type itself.
This allows the use of the same functions across multiple 
datatypes due to the excellent dispatch system in the Julia language.

```@example fileread
channelnames(s)
```

Similarly we can query the sample rate of the measurement:

```@example fileread
samplingrate(s)
```


## Preprocessing

```@example fileread
s = rereference(s, "Cz")
remove_channel!(s, ["Cz", "TP7"])
s
```


## Visualise processed continuous data

```@example fileread
using Plots # hide
plot_timeseries(s, channels="F6")
current() |> DisplayAs.PNG # hide
```

```@example fileread
using Plots # hide
plot_timeseries(s)
current() |> DisplayAs.PNG # hide
```

## Conclusion

A demonstration of how to read in EEG data was provided.
A brief explanation of how to query the returned data type was discussed.
Basic signal processing and plotting was demonstrated.
