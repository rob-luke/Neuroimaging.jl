facts("Volume Image") do
    fname = joinpath(dirname(@__FILE__), "../../data", "test-3d.dat")
    t = read_VolumeImage(fname)
    t2 = read_VolumeImage(fname)

    context("Reading") do
	t = read_VolumeImage(fname)
	@fact isa(t, EEG.VolumeImage) --> true
    end

    context("Create") do
        # Array
	n = VolumeImage(t.data, t.units, t.x, t.y, t.z, t.t, t.method, t.info, t.coord_system)
	@fact isa(n, EEG.VolumeImage) --> true
        @fact isequal(n.data, t.data) --> true

        # Vector
        d = zeros(length(t.data))
        x = zeros(length(t.data))
        y = zeros(length(t.data))
        z = zeros(length(t.data))
        s = zeros(length(t.data))  # t is already taken
        i = 1
        for xi in 1:length(t.x)
            for yi in 1:length(t.y)
                for zi in 1:length(t.z)
                    for ti in 1:length(t.t)
                        d[i] = float(t.data[xi, yi, zi, ti])
                        x[i] = float(t.x[xi])
                        y[i] = float(t.y[yi])
                        z[i] = float(t.z[zi])
                        s[i] = float(t.t[ti])
                        i += 1
                    end
                end
            end
        end
        n2 = VolumeImage(d, t.units, x, y, z, s, t.method, t.info, t.coord_system)
        @fact isa(n2, EEG.VolumeImage) --> true
        @fact isequal(n2.data, t.data) --> true
        @fact isequal(n2.x, t.x) --> true
        @fact isequal(n2.y, t.y) --> true
        @fact isequal(n2.z, t.z) --> true
        @fact isequal(n2.t, t.t) --> true

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
    	@fact size(dips) --> (16,)

    	#dips = EEG.new_dipole_method(mean(t))
    	#@fact size(dips) --> (9,)

    	fname = joinpath(dirname(@__FILE__), "../../data", "test-4d.dat")
    	t2 = read_VolumeImage(fname)
    	dips = find_dipoles(mean(t2))
    	@fact size(dips) --> (3,)

    	# Test dipoles are returned in order of size
    	@fact issorted([dip.size for dip in dips], rev = true) --> true
    end

    context("Best Dipole") do

        # dips = find_dipoles(mean(t))
        # # Plots.pyplot(size=(1400, 400))
        # # p = plot(t, c = :inferno)
        # # p = plot(p, Talairach(-0.04, 0.01, 0.02))
        # bd = best_dipole(Talairach(-0.05, 0, 0.01), dips)
        # #p = plot(p, Talairach(-0.05, 0, 0.01), c = :red)
		#
        # @fact float(bd.x) --> roughly(-0.0525, atol =  0.001)
        # @fact float(bd.y) --> roughly(-0.00378, atol =  0.001)
        # @fact float(bd.z) --> roughly(0.0168099, atol =  0.001)
		#
        # # Take closest
        # bd = best_dipole(Talairach(-0.05, 0, 0.01), dips, maxdist = 0.0015)
        # @fact float(bd.x) --> roughly(-0.0525, atol =  0.001)
        # @fact float(bd.y) --> roughly(-0.00378, atol =  0.001)
        # @fact float(bd.z) --> roughly(0.0168099, atol =  0.001)
		#
        # # Take only valid dipole
        # dists = [euclidean(Talairach(-0.05, 0, 0.01), dip) for dip=dips]
        # bd = best_dipole(Talairach(-0.05, 0, 0.01), dips, maxdist = 0.015)
        # @fact float(bd.x) --> roughly(-0.0525, atol =  0.001)
        # @fact float(bd.y) --> roughly(-0.00378, atol =  0.001)
        # @fact float(bd.z) --> roughly(0.0168099, atol =  0.001)
		#
        # bd = best_dipole(Talairach(-0.05, 0, 0.01), Dipole[])
        # @fact isnan(bd) --> true

    end

    context("Show") do
    	@suppress_out show(t)
    	@suppress_out show(normalise(t))
    	t.info["Regularisation"] = 1.2
    	@suppress_out show(t)
    end

    context("Plotting") do
    	EEG.plot(mean(t))
    	EEG.plot(mean(t), min_val = 0, max_val = 50)
        EEG.plot(mean(t), elp = joinpath(dirname(@__FILE__), "../../data", "test.elp"))
    	p = EEG.plot(mean(t), threshold = 24 )

        context("Overlay dipole") do

            dips = find_dipoles(mean(t))
            p = plot(p, dips)
            p = plot(p, dips[1], c = :red)

        end
    end
end
