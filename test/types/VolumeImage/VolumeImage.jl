@testset "Volume Image" begin
    fname = joinpath(dirname(@__FILE__), "../../data", "test-3d.dat")
    t = read_VolumeImage(fname)
    t2 = read_VolumeImage(fname)

    @testset "Reading" begin
        t = read_VolumeImage(fname)
        @test isa(t, EEG.VolumeImage) ==  true
    end

    @testset "Create" begin
        # Array
        n = VolumeImage(t.data, t.units, t.x, t.y, t.z, t.t, t.method, t.info, t.coord_system)
        @test isa(n, EEG.VolumeImage) == true
        @test isequal(n.data, t.data) == true

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
                        d[i] = ustrip(t.data[xi, yi, zi, ti])
                        x[i] = ustrip(t.x[xi])
                        y[i] = ustrip(t.y[yi])
                        z[i] = ustrip(t.z[zi])
                        s[i] = ustrip(t.t[ti])
                        i += 1
                    end
                end
            end
        end
        n2 = VolumeImage(d, t.units, x, y, z, s, t.method, t.info, t.coord_system)
        @test isa(n2, EEG.VolumeImage) == true
        @test isequal(n2.data, t.data) == true
        @test isequal(n2.x, t.x) == true
        @test isequal(n2.y, t.y) == true
        @test isequal(n2.z, t.z) == true
        @test isequal(n2.t, t.t) == true

    end

    @testset "Maths" begin

        @test isequal(t, t2) == true

        @test t + t ==  t * 2
        t4 = t * 4
        @test t4 / 2 == t + t
        @test t4 / 2 == t4 - t - t

        t2 = read_VolumeImage(fname)
        t2.units = "A/m^3"
        # @test_throws t + t2
    end

    @testset "Min/Max" begin

        @test maximum(t) == 33.2692985535
        @test minimum(t) == -7.5189352036

        b = t * 2

        @test b.data[1, 1, 1] == 2 * b.data[1, 1, 1]
        @test b.data[2, 2, 2] == 2 * b.data[2, 2, 2]

        c = mean([b, t])

        @test size(c.data) == size(b.data)
        @test c.data[1, 1, 1] == (b.data[1, 1, 1] + t.data[1, 1, 1]) / 2

        @test maximum([b, t]) == maximum(t) * 2
        @test minimum([b, t]) == minimum(b)

        n = normalise([b, t])

        @test maximum(n) <= 1.0
        @test minimum(n) >= -1.0

    end


    @testset "Dimension checks" begin
        t2 = deepcopy(t); t2.x = t2.x[1:3]
        @test_throws KeyError EEG.dimensions_equal(t, t2)
        t2 = deepcopy(t); t2.y = t2.y[1:3]
        @test_throws KeyError EEG.dimensions_equal(t, t2)
        t2 = deepcopy(t); t2.z = t2.z[1:3]
        @test_throws KeyError EEG.dimensions_equal(t, t2)
        t2 = read_VolumeImage(joinpath(dirname(@__FILE__), "../../data", "test-4d.dat"))
        @test_throws KeyError EEG.dimensions_equal(t, t2)
    end


    @testset "Average" begin
        s = mean(t)
    end

    @testset "Find dipoles" begin

        t = read_VolumeImage(fname)
        dips = find_dipoles(mean(t))
        @test size(dips) == (16,)

        #dips = EEG.new_dipole_method(mean(t))
        #@test size(dips) == (9,)

        fname = joinpath(dirname(@__FILE__), "../../data", "test-4d.dat")
        t2 = read_VolumeImage(fname)
        dips = find_dipoles(mean(t2))
        @test size(dips) == (3,)

        # Test dipoles are returned in order of size
        @test issorted([dip.size for dip in dips], rev = true) == true
    end

    @testset "Best Dipole" begin

        # dips = find_dipoles(mean(t))
        # # Plots.pyplot(size=(1400, 400))
        # # p = plot(t, c = :inferno)
        # # p = plot(p, Talairach(-0.04, 0.01, 0.02))
        # bd = best_dipole(Talairach(-0.05, 0, 0.01), dips)
        # #p = plot(p, Talairach(-0.05, 0, 0.01), c = :red)
        #
        # @test float(bd.x) == roughly(-0.0525, atol =  0.001)
        # @test float(bd.y) == roughly(-0.00378, atol =  0.001)
        # @test float(bd.z) == roughly(0.0168099, atol =  0.001)
        #
        # # Take closest
        # bd = best_dipole(Talairach(-0.05, 0, 0.01), dips, maxdist = 0.0015)
        # @test float(bd.x) == roughly(-0.0525, atol =  0.001)
        # @test float(bd.y) == roughly(-0.00378, atol =  0.001)
        # @test float(bd.z) == roughly(0.0168099, atol =  0.001)
        #
        # # Take only valid dipole
        # dists = [euclidean(Talairach(-0.05, 0, 0.01), dip) for dip=dips]
        # bd = best_dipole(Talairach(-0.05, 0, 0.01), dips, maxdist = 0.015)
        # @test float(bd.x) == roughly(-0.0525, atol =  0.001)
        # @test float(bd.y) == roughly(-0.00378, atol =  0.001)
        # @test float(bd.z) == roughly(0.0168099, atol =  0.001)
        #
        # bd = best_dipole(Talairach(-0.05, 0, 0.01), Dipole[])
        # @test isnan(bd) == true

    end

    @testset "Show" begin
        show(t)
        show(normalise(t))
        t.info["Regularisation"] = 1.2
        show(t)
    end

    @testset "Plotting" begin
        EEG.plot(mean(t))
        EEG.plot(mean(t), min_val = 0, max_val = 50)
        EEG.plot(mean(t), elp = joinpath(dirname(@__FILE__), "../../data", "test.elp"))
        p = EEG.plot(mean(t), threshold = 24 )

        @testset "Overlay dipole" begin

            dips = find_dipoles(mean(t))
            p = plot(p, dips)
            p = plot(p, dips[1], c = :red)

        end
    end
end
