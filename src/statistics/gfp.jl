#######################################
#
# Global field power
#
#######################################

function gfp(x::Array)

    samples, sensors = size(x)

    info("Computing global field power for $sensors sensors and $samples samples")

    result = zeros(samples,1)

    for sample = 1:samples
        u = vec(x[sample,:]) .- mean(x[sample,:])
        sumsqdif = 0
        for sensor = 1:sensors
            for sensor2 = 1:sensors
                sumsqdif += (u[sensor] - u[sensor2])^2
            end
        end
        result[sample] = sqrt.(sumsqdif / (2*length(samples)))
    end

    return result
end
