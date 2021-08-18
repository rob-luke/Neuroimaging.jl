push!(LOAD_PATH,"../src/")
using Documenter, EEG

makedocs(
    modules = [EEG],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "EEG.jl",
    authors  = "Robert Luke",
    pages = [
        "Home" => "index.md",
        "Types" => "types.md",
        "Steady State Responses" => Any[
            "Overview" => "assr.md",
            "Example" => "examples.md",
            "API" => "functions.md",
        ],
        "API" => "api.md"
    ]
)

deploydocs(
    repo = "github.com/rob-luke/EEG.jl.git",
    push_preview = true,
    devbranch = "main"
)
