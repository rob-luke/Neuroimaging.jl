facts("Dipoles") do

    dips = Dipole[]

    context("Create") do

        dip1 = Dipole("Talairach", 1, 2, 1, 0, 0, 0, 1, 1, 1)
        dip2 = Dipole("Talairach", 1, 2, 3, 0, 0, 0, 2, 2, 2)

        dips = push!(dips, dip1)
        dips = push!(dips, dip2)

        @fact length(dips) --> 2
    end

    context("Show") do

        @suppress_out show(dips[1])
        @suppress_out show(dips)
    end


    context("Mean") do

        b = mean(dips)
        @fact b.x --> 1.0 * SIUnits.ShortUnits.m
        @fact b.y --> 2.0 * SIUnits.ShortUnits.m
        @fact b.z --> 2.0 * SIUnits.ShortUnits.m
    end

    context("Std") do

        b = std(dips)
        @fact b.x --> 0.0 * SIUnits.ShortUnits.m
        @fact b.y --> 0.0 * SIUnits.ShortUnits.m
        @fact b.z --> std([1, 3]) * SIUnits.ShortUnits.m
    end
end
