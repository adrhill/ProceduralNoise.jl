using Random

x, y, z = rand(MersenneTwister(1234), Float32, 3)

# Dryrun
n = @inferred perlin3d(x, y, z)
@test n ≈ 0.547249

n = @inferred perlin(x, y, z)
@test n ≈ 0.547249
