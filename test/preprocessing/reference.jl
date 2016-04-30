facts("Referencing") do
    context("Remove template") do

	signals = [0 1 2] .* ones(5, 3)
	template = vec(2 * ones(5))
	@fact remove_template(signals, template) -->  [-2 -1 0] .* ones(5, 3)
	@fact_throws remove_template(signals, [1, 2, 3])

    end
    context("Reference to channel") do
    end

    context("Reference to group of channels") do
    end
end
