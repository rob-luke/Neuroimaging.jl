## Plot estimated neural activity

```julia
using EEG, Winston

x, y, z, s, t = read_dat("example.dat")

s = squeeze(mean(s, 4), 4)

f = plot_dat(x, y, z, s, ncols=2, threshold=0, max_size=1)

Winston.savefig(f, "source.pdf", height = 600, width=600)

```

![PNG](https://raw.githubusercontent.com/codles/EEG.jl/master/doc/images/sources.png)
