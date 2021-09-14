# Source Modelling

`Neuroimaging.jl` supports opening volume image data.
In this example we open a `.dat` file as is
exported by the BESA software.

Volume image data represents the estimated activity
at each source location. The magnitude of the activity
can be displayed in a figure (see below).

In this example we read data from an EEG distributed source analysis procedure
run in the BESA software using the CLARA approach (Jordanov T., Hoechstetter K., Berg P., Paul-Jordanov I., Scherg M. CLARA: classical LORETA analysis recursively applied. F1000Posters. 2014;5:895.).

```@example fileread
using DisplayAs, Plots # hide
using Neuroimaging
data_path = joinpath("..", "..", "..", "test", "data", "test-3d.dat")

t = read_VolumeImage(data_path)
```


## Plotting

Next we can view the volume image by calling the plot method on it.
Note that each dot represents the distributed source activity at that
location, in this location the estimates are in units nAm/cm^3.

```@example fileread
Neuroimaging.plot(t)
current() |> DisplayAs.PNG # hide
```