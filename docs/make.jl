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
        "Steady State Responses" => Any[
            "Overview"=>"assr/assr.md",
            "Example"=>"assr/examples.md",
            "API"=>"assr/functions.md",
        ],
        "API" => "api.md",
    ],
)

deploydocs(repo = "github.com/rob-luke/EEG.jl.git", push_preview = true, devbranch = "main")
