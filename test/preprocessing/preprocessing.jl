facts("Preprocessing") do

    fname = joinpath(dirname(@__FILE__),  "..", "data", "test_Hz19.5-testing.bdf")
    s = read_SSR(fname)

    context("Triggers") do

        context("Validation") do

            validate_triggers(s.triggers)

            s1 = deepcopy(s)
            delete!(s1.triggers, "Index")
            @fact_throws KeyError validate_triggers(s1.triggers)

            s1 = deepcopy(s)
            delete!(s1.triggers, "Code")
            @test_throws KeyError validate_triggers(s1.triggers)

            s1 = deepcopy(s)
            delete!(s1.triggers, "Duration")
            @test_throws KeyError validate_triggers(s1.triggers)

            s1 = deepcopy(s)
            s1.triggers["test"] = 1
            validate_triggers(s1.triggers)

            s1 = deepcopy(s)
            s1.triggers["Duration"] = s1.triggers["Duration"][1:4]
            @test_throws KeyError validate_triggers(s1.triggers)

            s1 = deepcopy(s)
            s1.triggers["Code"] = s1.triggers["Code"][1:4]
            @test_throws KeyError validate_triggers(s1.triggers)

        end
    end
end


facts("Referencing") do

    signals = [0 1 2] .* ones(5, 3)

    context("Remove template") do

	signals = [0 1 2] .* ones(5, 3)
	template = vec(2 * ones(5))
	@fact remove_template(signals, template) -->  [-2 -1 0] .* ones(5, 3)
	@fact_throws remove_template(signals, [1, 2, 3])

    end
    context("Reference to channel") do

	@fact rereference(signals, 3) --> [-2 -1 0] .* ones(5, 3)
	@fact rereference(signals, "C2", ["C1", "C2", "C3"]) --> [-1 0 1] .* ones(5, 3)

    end

    context("Reference to group of channels") do

	@fact rereference(signals, [1, 2, 3]) --> [-1 0 1] .* ones(5, 3)
	@fact rereference(signals, ["C2", "C1", "C3"], ["C1", "C2", "C3"]) --> [-1 0 1] .* ones(5, 3)
	@fact rereference(signals, "car", ["C1", "C2", "C3"]) --> [-1 0 1] .* ones(5, 3)
	@fact rereference(signals, "average", ["C1", "C2", "C3"]) --> [-1 0 1] .* ones(5, 3)

    end
end
