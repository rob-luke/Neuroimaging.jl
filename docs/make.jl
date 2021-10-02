push!(LOAD_PATH, "../src/")
using Documenter, Neuroimaging

makedocs(
    modules = [Neuroimaging],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "Neuroimaging.jl",
    authors = "Robert Luke",
    pages = [
        "Home" => "index.md",
        "Types" => "types.md",
        "Usage/Implementation Details" =>
            Any["Accessing data"=>"usage/access.md", "Filtering"=>"usage/filter.md"],
        "General EEG Processing" => Any[
            "Overview"=>"eeg/eeg.md",
            "Example"=>"eeg/examples.md",
            "API"=>"eeg/functions.md",
        ],
        "Steady State Responses (EEG)" => Any[
            "Overview"=>"assr/assr.md",
            "Example"=>"assr/examples.md",
            "API"=>"assr/functions.md",
        ],
        "Transient Responses (EEG)" =>
            Any["Overview"=>"tr/transient.md", "Example"=>"tr/examples.md"],
        "Coordinate Systems" => Any["Example"=>"coord/examples.md",],
        "Source Modelling" => Any["Example"=>"source/examples.md",],
        "Input/Output Support" => "IO.md",
        "Low-Level API" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/rob-luke/Neuroimaging.jl.git",
    push_preview = true,
    devbranch = "main",
)
