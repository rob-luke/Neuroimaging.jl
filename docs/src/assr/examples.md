# Example

This tutorial demonstrates how to analyse an EEG measurement
that was acquired while the participant was listening to a modulated
noise. This stimulus should evoke an Auditory Steady State Response (ASSR)
that can be observed in the signal.

The stimulus was modulated at 40.0391 Hz. As such, the frequency content of
the signal will be examined. An increase in stimulus locked activity is
expected at the modulation rate and harmonics, but not other frequencies.


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

s = read_SSR(data_path)
```

The function will extract the modulation from the function name if available.
In this case the file name was not meaningful, and so we must inform the software of
information that is essential to analysis, but not stored in the data.
When analysing a steady state response a modulation rate is required.
Which can be set according to:

```@example fileread
s.modulationrate = 40.0391u"Hz"
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

Simillarly we can query the sample rate of the measurement:

```@example fileread
samplingrate(s)
```

Or the trigger information that was imported with the data:

```@example fileread
s.triggers
# Note, this will change see 
# https://github.com/rob-luke/Neuroimaging.jl/issues/123
# https://github.com/rob-luke/Neuroimaging.jl/issues/101
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
using Plots # hide
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

s = ftest(s, freq_of_interest=[10:38; 42:200])

s.processing["statistics"]["Significant"] = Int.(s.processing["statistics"]["Statistic"] .< 0.05)

s.processing["statistics"]
```

## Visualise response amplitude

```@example fileread
using DataFrames, StatsPlots, Query, Statistics

df = s.processing["statistics"] |> 
    @groupby(_.AnalysisFrequency) |> 
    @map({AnalysisFrequency=key(_),
        AverageAmplitude=Statistics.mean(_.SignalAmplitude),
        AverageStatistic=Int(Statistics.mean(_.Statistic).<0.05)}) |>
    @orderby_descending(_.AnalysisFrequency) |> 
    DataFrame

df |> @df StatsPlots.scatter(:AnalysisFrequency, :AverageAmplitude, color=:AverageStatistic, ms=6, lab="")
df |> @df StatsPlots.plot!(:AnalysisFrequency, :AverageAmplitude, xlabel="Frequency (Hz)", ylabel="Amplitude (uV)", lab="")
current() |> DisplayAs.PNG # hide
```

