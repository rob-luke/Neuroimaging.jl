# Source Modelling

Can open volume image data.
In this example we open a `.dat` file as is
exported by the BESA software.


```@example fileread
pwd()
```


```@example fileread
using DisplayAs # hide
using Neuroimaging, DataDeps, Unitful
data_path = joinpath("..", "..", "..", "test", "data", "test-3d.dat")

t = read_VolumeImage(data_path)
```


## Plotting


```@example fileread
Neuroimaging.plot(t)
current() |> DisplayAs.PNG # hide
```