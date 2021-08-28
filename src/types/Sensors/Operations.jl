"""
    match_sensors(sens::Array{S}, lbls::Array{AS}) where {AS<:AbstractString, S<:Sensor}

Match a set of electrodes to those provided

# Examples
```julia
lf, valid = match_sensors(electrodes, sensor_labels)
```
"""
function match_sensors(sens::Array{S}, lbls::Array{AS}) where {AS<:AbstractString,S<:Sensor}

    valid_idx = Int[]
    for label in lbls
        matched_idx = something(findfirst(isequal(label), labels(sens)), 0)
        if matched_idx != 0
            push!(valid_idx, matched_idx)
        end
        @debug(
            "Label $label matched to $( matched_idx == 0 ? "!! nothing !!" : sens[matched_idx].label)"
        )
    end

    sens = sens[valid_idx]

    return sens, valid_idx
end


function match_sensors(
    lf::Array,
    lf_labels::Array{S},
    labels::Array{S},
) where {S<:AbstractString}
    # Match the sensors in a leadfield array to those provided
    #
    # usage: lf, valid = match_sensors(leadfield, leadfield_labels, sensor_labels)

    valid_idx = Int[]
    for label in labels
        matched_idx = something(findfirst(isequal(label), lf_labels), 0)
        if matched_idx != 0
            push!(valid_idx, matched_idx)
        end
        @debug(
            "Label $label matched to $( matched_idx == 0 ? "!! nothing !!" : lf_labels[matched_idx])"
        )
    end

    @info(
        "Leadfield had $(length(lf_labels)) channels, now has $(length(valid_idx)) channels"
    )

    lf = lf[:, :, valid_idx]
    lf_labels = lf_labels[valid_idx]

    return lf, valid_idx
end


