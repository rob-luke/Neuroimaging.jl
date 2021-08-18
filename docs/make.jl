push!(LOAD_PATH,"../src/")
using Documenter, EEG

makedocs(
    modules = [EEG],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "EEG.jl",
    authors  = "Robert Luke",
)

deploydocs(
    repo = "github.com/rob-luke/EEG.jl.git",
    devbranch = "main"
)
