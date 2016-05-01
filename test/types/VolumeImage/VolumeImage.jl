facts("Volume Image") do
    fname = joinpath(dirname(@__FILE__), "../../data", "test-4d.dat")
    t = read_VolumeImage(fname)
    t2 = read_VolumeImage(fname)

    context("Reading") do
	t = read_VolumeImage(fname)
	@fact isa(t, EEG.VolumeImage) --> true
    end

    context("Create") do
	n = VolumeImage(t.data, t.units, t.x, t.y, t.z, t.t, t.method, t.info, t.coord_system)
    end

    context("Maths") do

	@fact isequal(t, t2) --> true

        @fact t + t --> t * 2
	t4 = t * 4
	@fact t4 / 2 --> t + t
	@fact t4 / 2 --> t4 - t - t

	t2 = read_VolumeImage(fname)
	t2.units = "A/m^3"
	@fact_throws t + t2

    end

    context("Average") do
	s = mean(t)
    end

    context("Show") do
	show(t)
    end

    context("Plotting") do
	EEG.plot(mean(t))
    end
end



