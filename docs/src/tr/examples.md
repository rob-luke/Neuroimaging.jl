# Transient Responses

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

s = read_TR(data_path)
```
