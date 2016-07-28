facts("Sensors") do

    fname = joinpath(dirname(@__FILE__), "..", "..", "data", "test.sfp")
    s = read_sfp(fname)


    context("Read file") do

        s = read_sfp(fname)
        @fact length(s) --> 3
    end


    context("Show") do

        show(s)
        show(s[1])
    end


    context("Matching") do

        a, b = match_sensors(s, ["Fp1", "Fp2"])

    end


    context("Leadfield matching") do

        L = ones(4, 3, 5)
        L[:, :, 2] = L[:, :, 2] * 2
        L[:, :, 3] = L[:, :, 3] * 3
        L[:, :, 4] = L[:, :, 4] * 4
        L[:, :, 5] = L[:, :, 5] * 5

        L, idx = match_sensors(L, ["meh", "Cz", "Fp1", "Fp2", "eh"], ["Fp2", "Cz"])

        @fact size(L) --> (4, 3, 2)
        @fact L[:, :, 1] --> ones(4, 3) * 4
        @fact L[:, :, 2] --> ones(4, 3) * 2
        @fact idx --> [4, 2]

    end


    context("Standard sets") do

        @fact length(EEG_64_10_20) --> 64
        @fact length(EEG_Vanvooren_2014) --> 18
        @fact length(EEG_Vanvooren_2014_Left) --> 9
        @fact length(EEG_Vanvooren_2014_Right) --> 9

    end

end
