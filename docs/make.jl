using Documenter, EEG

makedocs()

deploydocs(
    repo = "github.com/codles/EEG.jl.git",
    julia = "0.5",
)
