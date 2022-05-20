module ProceduralNoise

include("interpolation.jl")
include("perlin.jl")

export smoothstep, smootherstep
export perlin, perlin3d, octaveperlin, octaveperlin3d
end # module
