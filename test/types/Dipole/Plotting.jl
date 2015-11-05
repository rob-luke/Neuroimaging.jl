fname = joinpath(dirname(@__FILE__), "../../data", "test-3d.dat")

t = read_VolumeImage(fname)

p = EEG.plot(t, title = "With 2 Largest Dipoles")

dips = find_dipoles(t)

p = oplot(p, dips,  color="blue", size=4, symbolkind="square", ncols=3)

Winston.savefig(p, joinpath(dirname(@__FILE__), "../../data/tmp/",
	"test-plot-VolumeImage-w-dipoles.png"), height = 300, width = 900)


println()
println("!! Volume image plotting test passed !!")
println()
