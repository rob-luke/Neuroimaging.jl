abstract Sensor

type Electrode <: Sensor
    label::AbstractString
    coordinate::Coordinate
    info::Dict
end


import Base.show
function show{S <: Sensor}(s::S)
    println("Sensor: $(s.label) $(typeof(s)) - ($(s.coordinate.x), $(s.coordinate.y), $(s.coordinate.z)) ($(typeof(s.coordinate)))")
end

function show{S <: Sensor}(s::Array{S})
    println("$(length(s)) sensors: $(typeof(s[1])) ($(typeof(s[1].coordinate)))")
end


label{S <: Sensor}(s::S) = s.label
label{S <: Sensor}(s::Array{S, 1}) = AbstractString[si.label for si in s]
labels{S <: Sensor}(s::S) = label(s)
labels{S <: Sensor}(s::Array{S}) = label(s)

x{S <: Sensor}(s::S) = s.coordinate.x
y{S <: Sensor}(s::S) = s.coordinate.y
z{S <: Sensor}(s::S) = s.coordinate.z
x{S <: Sensor}(s::Array{S}) = AbstractFloat[si.coordinate.x for si in s]
y{S <: Sensor}(s::Array{S}) = AbstractFloat[si.coordinate.y for si in s]
z{S <: Sensor}(s::Array{S}) = AbstractFloat[si.coordinate.z for si in s]


