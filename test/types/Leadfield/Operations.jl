ldf = Leadfield(rand(5, 3, 2), collect(1:5.0), collect(1:5.0), collect(1:5.0), ["ch1", "ch2"])

for n = 1:size(ldf.L, 1)
    @test n == find_location(ldf, Talairach(ldf.x[n], ldf.y[n], ldf.z[n]))
end


for n = 1:size(ldf.L, 1)
    @test n == find_location(ldf, Talairach(ldf.x[n]+0.1, ldf.y[n]-0.1, ldf.z[n]))
end
