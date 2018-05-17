abstract type Sensor end

mutable struct Electrode <: Sensor
    label::AbstractString
    coordinate::Coordinate
    info::Dict
end


import Base.show
function show(s::S) where S <: Sensor
    println("Sensor: $(s.label) $(typeof(s)) - ($(s.coordinate.x), $(s.coordinate.y), $(s.coordinate.z)) ($(typeof(s.coordinate)))")
end

function show(s::Array{S}) where S <: Sensor
    println("$(length(s)) sensors: $(typeof(s[1])) ($(typeof(s[1].coordinate)))")
end


label(s::S) where {S <: Sensor} = s.label
label(s::Array{S, 1}) where {S <: Sensor} = AbstractString[si.label for si in s]
labels(s::S) where {S <: Sensor} = label(s)
labels(s::Array{S}) where {S <: Sensor} = label(s)

x(s::S) where {S <: Sensor} = s.coordinate.x
y(s::S) where {S <: Sensor} = s.coordinate.y
z(s::S) where {S <: Sensor} = s.coordinate.z
x(s::Array{S}) where {S <: Sensor} = AbstractFloat[si.coordinate.x for si in s]
y(s::Array{S}) where {S <: Sensor} = AbstractFloat[si.coordinate.y for si in s]
z(s::Array{S}) where {S <: Sensor} = AbstractFloat[si.coordinate.z for si in s]


