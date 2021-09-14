## This project is currently being revitalised. See progress [here](https://github.com/rob-luke/Neuroimaging.jl/projects/1)

This package has been around since Julia v0.1!
The Julia language has evolved since the early days,
and there are many places in the codebase that should be bought up to date with the latest Julia standards. 
The general plan is:

- [x] 1. Get the existing code working, documented, and tested
  - [x] Enable the continuous integration
  - [x] Remove all errors thrown by code
  - [x] Ensure current code base runs with the latest version of Julia (1.6)
  - [x] Remove code warnings and update dependency packages
  - [x] Document existing code and raise issues for known shortcomings. I.e., note all code that needs to be modernised
  - [x] Add help on how to contribute to the documentation 
- [ ] 2. Improve the package
  - [ ] Modernise the code base to meet Julia 1 best practices
  - [ ] Generalise many of the concepts and add new analysis types and examples
  - [ ] Start chipping away at improvements! Pull requests are appreciated for any aspect of the code base

**In general I am pleased to welcome contributions and improvements to all aspects of this project.**
The current code base is a starting point, but I am happy to integrate improvements to any aspect of the code.
Any code changes must allow for the existing examples analysis to work (but its ok to change API etc).


# Neuroimaging

Process neuroimaging data in [Julia](http://julialang.org/).  


## Status

[![Documentation](https://img.shields.io/badge/Documentation-dev-green)](https://rob-luke.github.io/Neuroimaging.jl/)
[![Tests Julia 1](https://github.com/rob-luke/Neuroimaging.jl/actions/workflows/runtests.yml/badge.svg)](https://github.com/rob-luke/Neuroimaging.jl/actions/workflows/runtests.yml)
[![codecov](https://codecov.io/gh/rob-luke/Neuroimaging.jl/branch/main/graph/badge.svg?token=8IY5Deklvg)](https://codecov.io/gh/rob-luke/Neuroimaging.jl)


## Documentation

See https://rob-luke.github.io/Neuroimaging.jl
