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
