facts("Coordinates") do

    context("Create") do
        context("Brain Vision") do
            bv = BrainVision(0, 0, 0)
            context("Show") do
                @suppress_out show(bv)
            end
        end
        context("Talairach") do
            tal = Talairach(68.3, -26.9, 8.3)
            context("Show") do
                @suppress_out show(tal)
            end
        end
        context("SPM") do
            spm = SPM(68.3, -26.9, 8.3)
            context("Show") do
                @suppress_out show(spm)
            end
        end
        context("Unknown") do
            uk = UnknownCoordinate(1.2, 2, 3.2)
            context("Show") do
                @suppress_out show(uk)
            end
        end
    end


    context("Convert") do
        context("MNI -> Talairach") do

            # Values from table IV in Lancaster et al 2007
            # TODO Find better points to translate

            mni = SPM(73.7, -26.0, 7.0)
            tal = Talairach(68.3, -26.9, 8.3)
            @fact euclidean(convert(Talairach, mni), tal) --> roughly(0; atol=2)

            # As an electrode

            # Test as an electrode
            e = Electrode("test", SPM(73.7, -26.0, 7.0), Dict())
            e = conv_spm_mni2tal(e)

            @fact e.coordinate.x --> roughly(tal.x, 1.5)
            @fact e.coordinate.y --> roughly(tal.y, 1.5)
            @fact e.coordinate.z --> roughly(tal.z, 1.5)
            @fact isa(e, EEG.Sensor) --> true
            @fact isa(e, EEG.Electrode) --> true
            @fact isa(e.coordinate, EEG.Talairach) --> true

        end

        context("BrainVision -> Talairach") do

            # TODO this just tests it runs, need to check values

            bv = BrainVision(0, 0, 0)
            tal = Talairach(128, 128, 128)
            @fact euclidean(convert(Talairach, bv), tal) --> roughly(0; atol=1.5)

        end
    end


    context("Distances") do

        @fact euclidean(Talairach(0, 0, 0), Talairach(1, 1, 1)) --> sqrt.(3)

        v = [0, 0, 0]
        @fact euclidean(Talairach(1, 1, 1), v) --> sqrt.(3)
        @fact euclidean(v, Talairach(1, 1, 1)) --> sqrt.(3)

    end
end
