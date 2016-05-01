facts("Volume Image") do
    fname = joinpath(dirname(@__FILE__), "../../data", "test-3d.dat")
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

    context("Min/Max") do

	@fact maximum(t) --> 33.2692985535
	@fact minimum(t) --> -7.5189352036

	b = t * 2

	@fact b.data[1, 1, 1] --> 2 * b.data[1, 1, 1]
	@fact b.data[2, 2, 2] --> 2 * b.data[2, 2, 2]

	c = mean([b, t])

	@fact size(c.data) --> size(b.data)
	@fact c.data[1, 1, 1] --> (b.data[1, 1, 1] + t.data[1, 1, 1]) / 2

	@fact maximum([b, t]) --> maximum(t) * 2
	@fact minimum([b, t]) --> minimum(b)

	n = normalise([b, t])

	@fact maximum(n) --> less_than_or_equal(1.0)
	@fact minimum(n) --> greater_than_or_equal(-1.0)

    end


    context("Dimension checks") do
	t2 = deepcopy(t); t2.x = t2.x[1:3]
	@fact_throws KeyError EEG.dimensions_equal(t, t2)
	t2 = deepcopy(t); t2.y = t2.y[1:3]
	@fact_throws KeyError EEG.dimensions_equal(t, t2)
	t2 = deepcopy(t); t2.z = t2.z[1:3]
	@fact_throws KeyError EEG.dimensions_equal(t, t2)
	t2 = read_VolumeImage(joinpath(dirname(@__FILE__), "../../data", "test-4d.dat"))
	@fact_throws KeyError EEG.dimensions_equal(t, t2)
    end


    context("Average") do
	s = mean(t)
    end

    context("Find dipoles") do

	t = read_VolumeImage(fname)
	dips = find_dipoles(mean(t))
	@fact size(dips) --> (11,)

	fname = joinpath(dirname(@__FILE__), "../../data", "test-4d.dat")
	t2 = read_VolumeImage(fname)
	dips = find_dipoles(mean(t2))
	@fact size(dips) --> (5,)

	# Test dipoles are returned in order of size
	@fact issorted([dip.size for dip in dips], rev = true) --> true
    end


    context("Show") do
	show(t)
	show(normalise(t))
	t.info["Regularisation"] = 1.2
	show(t)
    end

    context("Plotting") do
	EEG.plot(mean(t))
    end
end



