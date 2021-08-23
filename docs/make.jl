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
        "Input/Output Support" => "IO.md",
        "Low-Level API" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/rob-luke/Neuroimaging.jl.git",
    push_preview = true,
    devbranch = "main",
)
