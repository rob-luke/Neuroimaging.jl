# Neuroimaging.jl Manual

A [Julia](http://julialang.org) package for processing neuroimaging data.

### Installation

To install this package enter the package manager by pressing `]` at the julia prompt and enter:

```julia
pkg> add Neuroimaging
```

### Overview

This package provides a framework for processing neuroimaging data.
It provides tools to handle high level data structures such as EEG data types,
electrode and optode sensor types, coordinate systems etc.
Low-level functions are also provided for operating on Julia native data types.

An overview of different data types is provided along with an example for each type and list of available functions.
This is followed by a list of the low-level function APIs.

!!! note "This package is in the process of being updated"

    This package has been around since Julia v0.1!
    The Julia language has evolved since the early days,
    and there are many places in the codebase that should be bought up to date with the latest Julia standards. 
    General improvements are planned to this package. But before changes are made,
    the existing features and functions will be documented. This will help to highlight
    what has already been implemented, and where improvements need to be made.
    For a rough plan of how the package is being redeveloped see the GitHub issues and
    [project board](https://github.com/rob-luke/Neuroimaging.jl/projects/1).


```@meta
CurrentModule = Neuroimaging
```
