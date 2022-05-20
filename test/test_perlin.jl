using Random

T = Float32
x, y, z = rand(MersenneTwister(1234), T, 3)

n = @inferred perlin(x, y, z)
@test typeof(n) == T
@test n ≈ 0.547249

n = @inferred octaveperlin(8, T(1.0), x, y, z)
@test typeof(n) == T
@test n ≈ 0.47737733

T = Float16
x, y, z = rand(MersenneTwister(1234), T, 3)

n = @inferred perlin(x, y, z)
@test typeof(n) == T
@test n ≈ 0.3982

n = @inferred octaveperlin(8, T(1.0), x, y, z)
@test typeof(n) == T
@test n ≈ 0.4492
