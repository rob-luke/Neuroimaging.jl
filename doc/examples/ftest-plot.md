## Plot F-test spectrum

```julia
using EEG, Gadfly

a = read_SSR("file.bdf")

# Preprocess data
a = highpass_filter(a)
a = rereference(a, "Cz")
a = merge_channels(a, EEG_Vanvooren_2014, "Merged")
    remove_channel!(a, EEG_64_10_20)
a = extract_epochs(a)
a = create_sweeps(a)

# Plot and save ftest spectrum
f = plot_ftest(a)
    draw(PNG("ftest.png", 16inch, 8inch), f)
```

![Ftest](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/ftest.png)
