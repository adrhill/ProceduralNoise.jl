using BenchmarkTools
using ProceduralNoise
using Random

on_CI = haskey(ENV, "GITHUB_ACTIONS")

T = Float32
x, y, z = rand(MersenneTwister(1234), T, 3)

# Define benchmark
SUITE = BenchmarkGroup()
SUITE["Perlin"] = BenchmarkGroup(["noise", "perlin"])
SUITE["Perlin"]["3D"] = BenchmarkGroup(["3d"])
SUITE["Perlin"]["3D"]["perlin"] = @benchmarkable perlin($x, $y, $z)
SUITE["Perlin"]["3D"]["octaveperlin"] = @benchmarkable octaveperlin($8, $T(2.0), $x, $y, $z)
