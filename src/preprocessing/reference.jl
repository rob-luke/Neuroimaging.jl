@doc """
Remove a template signal from each column of an array

#### Arguments

* `signals`: Original signals to be modified  (samples x channels)
* `template`: Template to remove from each signal

#### Returns
Signals with template removed
""" ->
function remove_template(signals::Array{T, 2}, template::AbstractVector{T}) where T <: AbstractFloat

    @assert size(signals, 1) == size(template, 1)

    for chan = 1:size(signals)[end]
        signals[:, chan] -=  template
    end

    return signals
end


@doc """
Re reference a signals to specific signal channel by index.

If multiple channels are specififed, their average is used as the reference.

#### Arguments

* `signals`: Original signals to be modified
* `refChan`: Index of channels to be used as reference

#### Returns

Rereferenced signals
""" ->
function rereference(signals::Array{T, 2}, refChan::Union{Int, Array{Int}}) where T <: AbstractFloat

    debug("Re referencing $(size(signals)[end]) channels to $(length(refChan)) channels")
    debug("Reference channels = $refChan")

    reference_signal = signals[:, refChan]

    # If using the average of several channels
    if size(reference_signal, 2) > 1
        reference_signal = vec(mean(reference_signal ,2))
    end

    remove_template(signals, reference_signal)
end


@doc """
Re-reference a signals to specific signal channel by name.

If multiple channels are specififed, their average is used as the reference.
Or you can specify to use the `average` reference.

#### Arguments

* `signals`: Original signals to be modified
* `refChan`: List of channels to be used as reference or `average`
* `chanNames`: List of channel names associated with signals array

#### Returns

Rereferenced signals
""" ->
function rereference(signals::Array{T, 2}, refChan::S, chanNames::Vector{S}) where {S <: AbstractString, T <: AbstractFloat}

    debug("Reference channels = $refChan")

    if refChan == "car" || refChan == "average"
        refChan_Idx = collect(1:size(signals, 2))
    elseif isa(refChan, AbstractString)
        refChan_Idx = findfirst(chanNames, refChan)
    end

    if refChan == 0; error("Requested channel is not in the provided list of channels"); end

    rereference(signals, refChan_Idx)
end


function rereference(signals::Array{T, 2}, refChan::Vector{S}, chanNames::Vector{S}) where {S <: AbstractString, T <: AbstractFloat}

    debug("Reference channels = $refChan")

    refChan_Idx = [findfirst(chanNames, i) for i = refChan]

    if refChan == 0; error("Requested channel is not in the provided list of channels"); end

    rereference(signals, refChan_Idx)
end
