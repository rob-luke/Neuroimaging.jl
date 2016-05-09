facts("File formats") do

    context("avr") do
        include("avr.jl")
    end
    context("bsa") do
        include("bsa.jl")
    end
    context("dat") do
        include("dat.jl")
    end
    context("elp") do
        include("elp.jl")
    end
    context("evt") do
        include("evt.jl")
    end
    context("rba") do
        include("rba.jl")
    end
    context("sfp") do
        include("rba.jl")
    end
end

