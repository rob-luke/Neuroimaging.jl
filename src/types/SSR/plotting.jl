"""
    plot_timeseries(s::SSR; channels, fs, kwargs)
    
Plot an SSR recording.

Plot detailed single channel or general multichanel figure depending on how many channels are requested.

#### Input

* `s`: SSR type
* `channels`: The channels you want to plot, all if not specified
* `fs`: Sample rate
* Other optional arguements are passed to the Plots.jl functions


#### Output

Returns a figure


#### Example

```julia
plot1 = plot_timeseries(s, channels=["P6", "Cz"], plot_points=8192*4)
draw(PDF("timeseries.pdf", 10inch, 6inch), plot1)
```

"""
function plot_timeseries(s::SSR; channels::Union{S, Array{S}} = channelnames(s),
        fs::Number = samplingrate(s), kwargs...) where S <: AbstractString

    if isa(channels, AbstractString) || length(channels) == 1 || size(s.data, 2) == 1

        @debug("Plotting single channel waveform for channel $channels  from channels $(channelnames(s))")

        fig = plot_single_channel_timeseries(vec(keep_channel!(deepcopy(s), channels).data), samplingrate(s); kwargs...)

    else

        # Find index of requested channels
        idx = [   something(findfirst(isequal(n), channelnames(s)), 0) for n in channels]
        idx = idx[idx .!= 0]   # But if you cant find channels then plot what you can
        if length(idx) != length(channels)
            @warn("Cant find index of all requested channels")
        end

        @debug("Plotting multi channel waveform for channels $(channelnames(s)[idx])")
        fig = plot_multi_channel_timeseries(s.data[:, idx], samplingrate(s), channelnames(s)[idx]; kwargs...)
    end

    return fig
end
