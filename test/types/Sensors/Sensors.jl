facts("Sensors") do

    fname = joinpath(dirname(@__FILE__), "..", "..", "data", "test.sfp")
    s = read_sfp(fname)


    context("Read file") do

        s = read_sfp(fname)
        @fact length(s) --> 3
    end


    context("Show") do

        @suppress_out show(s)
        @suppress_out show(s[1])
    end


    context("Info") do

        @fact label(s) --> ["Fp1", "Fpz", "Fp2"]
        @fact label(s[1]) --> "Fp1"
        @fact labels(s) --> ["Fp1", "Fpz", "Fp2"]
        @fact labels(s[1]) --> "Fp1"

        @fact EEG.x(s) --> [-27.747648, -0.085967, 27.676888]
        @fact EEG.x(s[1]) --> -27.747648

        @fact EEG.y(s) --> [98.803864, 103.555275, 99.133354]
        @fact EEG.y(s[1]) --> 98.803864

        @fact EEG.z(s) --> [34.338360, 34.357265, 34.457005]
        @fact EEG.z(s[1]) --> 34.338360
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
