# Auditory Steady State Response Example

This tutorial demonstrates how to analyse an EEG measurement
that was acquired while the participant was listening to a modulated
noise. This stimulus should evoke an Auditory Steady State Response (ASSR)
that can be observed in the signal.

The stimulus was modulated at 40.0391 Hz. As such, the frequency content of
the signal will be examined. An increase in stimulus locked activity is
expected at the modulation rate and harmonics, but not other frequencies.

A standard ASSR analysis is performed. After an introduction to the data
structure, a high pass filter is applied, the signal is referenced to Cz,
epochs are extracted then combined in to sweeps, then finally an f-test
is applied to the sweep data in the frequency domain. For further details on analysis see:

* Picton, Terence W. Human auditory evoked potentials. Plural Publishing, 2010.

* Luke, Robert, Astrid De Vos, and Jan Wouters. "Source analysis of auditory steady-state responses in acoustic and electric hearing." NeuroImage 147 (2017): 568-576.

* Luke, Robert, et al. "Assessing temporal modulation sensitivity using electrically evoked auditory steady state responses." Hearing research 324 (2015): 37-45.


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
s
```


## Preprocessing

```@example fileread
s = filter_highpass(s)
s = rereference(s, "Cz")
remove_channel!(s, "Cz")
s
```


## Visualise processed continuous data

```@example fileread
using Plots # hide
plot(s, "TP7")
current() |> DisplayAs.PNG # hide
```


## Epoch and combine data

To emphasise the stimulus locked nature of the response and combat clock drift
the signal is then cut in to epochs based on the trigger information.
To increase the available frequency resolution the epochs are
then concatenated in to sweeps.

```@example fileread
s = extract_epochs(s)
s = create_sweeps(s, epochsPerSweep = 8)
```


## Extract Steady State Response Statistics

Standard statistical tests can then be run on the data.
An ftest will automatically convert the sweeps in to the frequency domain and
apply the appropriate tests with sane default values.
By default, it analyses the modulation frequency.
The result is stored in the `statistics` processing log by default,
but this can be specified by the user.

```@example fileread
s = ftest(s)
s.processing["statistics"]
```


## Visualise spectrum

Next we can visualise the spectral content of the signal.
As the response statistics have already been computed,
this will be overlaid on the plot.

```@example fileread
plot_spectrum(s, 3)
current() |> DisplayAs.PNG # hide
```

## Quantify the false positive rate of statistical analysis

While its interesting to observe a significant response at the modulation rate as expected,
it is important to ensure that the false detection rate at other frequencies is not too high.
As such we can analyse all other frequencies from 10 to 400 Hz and quantify
the false detection rate.

For this example file the resulting false detection rate is slightly over 5%.

```@example fileread
using DataFrames, Query, Statistics

s = ftest(s, freq_of_interest=[10:38; 42:400])

s.processing["statistics"][!, "Significant"] = Int.(s.processing["statistics"][!, "Statistic"] .< 0.05)

s.processing["statistics"] |> 
    @groupby(_.AnalysisType) |> 
    @map({AnalysisType=key(_),
        FalseDiscoveryRate_Percentage=100*Statistics.mean(_.Significant)}) |>
    DataFrame
```


## Visualise response amplitude

Finally we can plot the ASSR spectrum.
You can use the same convenient function as above, but here we will demonstrate
how to do this using the `StatsPlot` library.
This is possible because the results are stored in the format of a data frame.

We will also mark with red dots the frequency components which
contained a significant stimulus locked response according to the f-test.
And we add a vertical line at the modulation rate.

```@example fileread
using StatsPlots

df = s.processing["statistics"] |> 
    @groupby(_.AnalysisFrequency) |> 
    @map({AnalysisFrequency=key(_),
        AverageAmplitude=Statistics.mean(_.SignalAmplitude),
        AverageStatistic=Int(Statistics.mean(_.Statistic).<0.05)}) |>
    @orderby_descending(_.AnalysisFrequency) |> 
    DataFrame

vline([40], ylims=(0, 0.3), colour="grey", line=:dash, lab="Modulation rate")
df |> @df StatsPlots.plot!(:AnalysisFrequency, :AverageAmplitude, xlabel="Frequency (Hz)", ylabel="Amplitude (uV)", lab="", color="black")
df|> @filter(_.AverageStatistic == 1) |> @df StatsPlots.scatter!(:AnalysisFrequency, :AverageAmplitude, color="red", ms=4, lab="Significant response")
current() |> DisplayAs.PNG # hide
```

## Conclusion

An analysis pipeline of a steady state response measurement has been demonstrated.
Importing the file and specifying the required information was described.
As was preprocessing and statistical analysis.
The false detection rate of the analysis was quantified.
Finally, a figure was created to summarise the underlying data and demonstrate the
increased stimulus locked response at the modulation rate.
