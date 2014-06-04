using Leadfield
using EEGjl

t = import_headmodel("/Users/rluke/Documents/GITs/Leadfield.jl/data/Default50Brain.srf",
                     "/Users/rluke/Documents/GITs/Leadfield.jl/data/Default50Brain.srf",
                     "/Users/rluke/Documents/GITs/Leadfield.jl/data/FEM_Default50MRI.loc",
                     "/Users/rluke/Documents/GITs/Leadfield.jl/data/FEM_Default50MRI-Aniso3_CR80.lft")
