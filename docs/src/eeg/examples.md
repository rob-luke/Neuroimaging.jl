# Example

This example demonstrates basic processing of an EEG measurement with Neuroimaging.jl`.
An example file is imported, and the basic properties of the data structure are reported
including sampling rate and channel information.
Simple preprocessing, such as referencing and channel manipulation is demonstrated.
And the data of a single channel and multiple channels is visualised.


## Import EEG measurement in to Neuroimaging.jl for analysis

The first step in this example is to import the required packages.
In addition to importing the `Neuroimaging.jl` package, the
`DataDeps` package is imported to facilitate access to the example dataset _ExampleSSR_
which contains an example EEG measurement in the Biosemi data format.

To read the data the function `read_EEG` is used.
This returns the data as a `GeneralEEG` type which stores EEG measurements that are not associated
with any particular experimental paradigm.

```@example fileread
using DisplayAs # hide
using Neuroimaging, DataDeps

data_path = joinpath(
    datadep"ExampleSSR",
    "Neuroimaging.jl-example-data-master",
    "neuroimaingSSR.bdf",
)

s = read_EEG(data_path)
```

To view a summary of the returned data simply call the returned variable.

```@example fileread
s
```


## Probe information about the EEG measurement

The summary output of the imported data only includes basic information.
Several functions are provided to access more detailed aspects of the recording.
To list the names of the channels in this measurement call:

```@example fileread
channelnames(s)
```

Similarly to query the sample rate of the measurement. 
Internally `Neuroimaging.jl` makes extensive use of the `Uniful` package and stores many values with their associated units.
To obtain the sampling rate in Hz as a floating point number call:

```@example fileread
samplingrate(s)
```

!!! tip "Accessing data structure fields"

    Note that we call the function `channelnames`, and do not access properties of the type itself.
    This allows the use of the same functions across multiple datatypes due to the excellent dispatch system in the Julia language.
    Accessing the fields of data types directly is not supported in `Neuroimaging.jl` and may break at any time.
    If you wish to access an internal type field and a function is not provided then raise a GitHub issue.


## Basic signal processing for EEG data

Once data is imported then standard preprocessing procedures can be applied.
For example to rereference the data to the `Cz` channel call:

```@example fileread
s = rereference(s, "Cz")
```

After which the Cz channel will not contain meaningful information any longer.
So you may wish to remove it from further analysis.
You can remove multiple channels by providing an array of channel names by calling:

```@example fileread
remove_channel!(s, ["Cz", "TP7"])
s
```

And the resulting data structure will now have less channels as the output describes.

## Visualise continuous EEG data

It is also useful to visualise the EEG data.
You can view a single channel or subset of channels by passing the string or strings you wish to plot.

```@example fileread
using Plots # hide
plot(s, "F6")
current() |> DisplayAs.PNG # hide
```

Or you can plot all channels by calling `plot` with no arguments.

```@example fileread
using Plots # hide
plot(s)
current() |> DisplayAs.PNG # hide
```


## Extract underlying data for custom analysis

You may wish to run your own analysis on the underlying raw data array.
To access the raw data call:

```@example fileread
data(s)
```

Or to access a subset of channels call:

```@example fileread
data(s, ["F6", "F5"])
```

## Conclusion

A demonstration of how to read in EEG data was provided.
A brief explanation of how to query the returned data type was discussed.
Basic signal processing and plotting was demonstrated.
