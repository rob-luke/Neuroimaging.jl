using Winston

#
# Test plotting of volume image type
#

fname = joinpath(dirname(@__FILE__), "../../data", "test-3d.dat")

t = read_VolumeImage(fname)

p = plot(t)

Winston.savefig(p, joinpath(dirname(@__FILE__), "../../data/tmp/",
	"test-plot-VolumeImage.png"), height = 300, width = 900)
	
Winston.savefig(p, joinpath(dirname(@__FILE__), "../../data/tmp/",
	"test-plot-VolumeImage.pdf"), height = 300, width = 900)


# Different number of columns

p = plot(t, ncols = 2)

Winston.savefig(p, joinpath(dirname(@__FILE__), "../../data/tmp/",
	"test-plot-VolumeImage-w-2colums.png"), height = 900, width = 900)

p = plot(t, ncols = 4)

Winston.savefig(p, joinpath(dirname(@__FILE__), "../../data/tmp/",
	"test-plot-VolumeImage-w-4colums.png"), height = 300, width = 1200)


# Custom title

p = plot(t, title = "With Custom Title")
 
Winston.savefig(p, joinpath(dirname(@__FILE__), "../../data/tmp/",
	"test-plot-VolumeImage-w-title.png"), height = 300, width = 900)


# Add a color bar and shift to 4 columns

p = plot(t, ncols = 4, colorbar = true, title = "with colorbar", colorbar_title = "test") # 

Winston.savefig(p, joinpath(dirname(@__FILE__), "../../data/tmp/",
	"test-plot-VolumeImage-w-colorbar.png"), height = 300, width = 1200)


# Plot negative values

p = plot(t, plot_negative = true, title = "With Negative Values")

Winston.savefig(p, joinpath(dirname(@__FILE__), "../../data/tmp/",
	"test-plot-VolumeImage-w-negativevalues.png"), height = 300, width = 900)


# All point sizes the same

p = plot(t, min_size = 0.5, max_size = 0.5, title = "Same Size Points")

Winston.savefig(p, joinpath(dirname(@__FILE__), "../../data/tmp/",
	"test-plot-VolumeImage-w-equalsize.pdf"), height = 300, width = 900)
	
	
#
# Test plotting of dipoles
#

fname = joinpath(dirname(@__FILE__), "../../data", "test-3d.dat")

t = read_VolumeImage(fname)

p = plot(t, title = "With 2 Largest Dipoles")

dips = find_dipoles(t)

for dip in dips[1:2]
	p = oplot(p, dip,  color="blue", size=4, symbolkind="square", ncols=3)
end

Winston.savefig(p, joinpath(dirname(@__FILE__), "../../data/tmp/",
	"test-plot-VolumeImage-w-dipoles.png"), height = 300, width = 900)
	

println()
println("!! Volume image plotting test passed !!")
println()