"""
Type for storing data acquired with a steady state response (SSR) experimental paradigm.

In addition to the functions available for all EEG types,
the SSR type supports:

* `modulationrate()`

The following standard names are used when saving data to the processing dictionary.

* `Name`: The identifier for the participant
* `Side`: Side of stimulation
* `Carrier_Frequency`: Carrier frequency of the stimulus
* `Amplitude`: Amplitude of the stimulus
* `epochs`: The epochs extracted from the recording
* `sweeps`: The extracted sweeps from the recording

#### Example

Put an example here

```julia
s = read_SSR("filename")
s.modulationrate = 40.0391u"Hz"
s = rereference(s, "Cz")
```

"""
mutable struct SSR <: EEG
    data::Array
    sensors::Array{Sensor}
    triggers::Dict
    system_codes::Dict
    samplingrate::typeof(1.0u"Hz")
    modulationrate::typeof(1.0u"Hz")
    reference_channel::Array{AbstractString,1}
    file_path::AbstractString
    file_name::AbstractString
    processing::Dict
    header::Dict
end


#######################################
#
# SSR info
#
#######################################




"""
Return the modulation rate of a steady state type.
If no type is provided, the modulation rate is returned as a floating point.

#### Example

Return the modulation rate of a recording

```julia
s = read_SSR(filename)
modulationrate(s)
```
"""
modulationrate(t, s::SSR) = convert(t, ustrip(s.modulationrate))
modulationrate(s::SSR) = modulationrate(AbstractFloat, s)


#######################################
#
# Show
#
#######################################

import Base.show
function Base.show(io::IO, a::SSR)
    time_length = round.(size(a.data, 1) / samplingrate(Float64, a) / 60)
    println(
        io,
        "SSR measurement of $time_length mins with $(size(a.data,2)) channels sampled at $(a.samplingrate)",
    )
    println(io, "  Modulation frequency: $(a.modulationrate )")

    if haskey(a.processing, "Amplitude")
        println(io, "  Stimulation amplitude: $(a.processing["Amplitude"]) dB")
    end
    if haskey(a.processing, "Name")
        println(io, "  Participant name: $(a.processing["Name"] )")
    end
    if haskey(a.processing, "Side")
        println(io, "  Stimulation side: $(a.processing["Side"] )")
    end
    if haskey(a.processing, "Carrier_Frequency")
        println(io, "  Carrier frequency: $(a.processing["Carrier_Frequency"] ) Hz")
    end

end


#######################################
#
# Helper functions
#
#######################################

function assr_frequency(
    rounded_freq::Number;
    stimulation_samplingrate::Number = 32000,
    stimulation_frames_per_epoch::Number = 32768,
)

    round.(rounded_freq / (stimulation_samplingrate / stimulation_frames_per_epoch)) *
    stimulation_samplingrate / stimulation_frames_per_epoch
end

function assr_frequency(rounded_freq::AbstractVector)

    [assr_frequency(f) for f in rounded_freq]
end
