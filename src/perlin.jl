# Based on https://gist.github.com/Flafla2/f0260a861be0ebdeef76

# Hash lookup table as defined by Ken Perlin
const PERMS1 = [151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7,
    225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247,
    120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33,
    88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134,
    139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220,
    105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80,
    73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86,
    164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38,
    147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189,
    28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101,
    155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232,
    178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12,
    191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181,
    199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236,
    205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180]

const PERMS = [PERMS1; PERMS1]

function gradient3d(hash::Int, x::T, y::T, z::T) where {T<:AbstractFloat}
    h = hash & 15
    u = h < 8 ? x : y
    v = if h < 4
        y
    elseif h == 12 || h == 14
        x
    else
        z
    end
    return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v)
end

function gradient(hash::Int, x::T...) where {T<:AbstractFloat}
    n = length(x)
    nc2 = n * (2 * n + 1) - 2 * n
    xf = tuple(x..., .-x...)
    table = Array{T,2}(undef, (nc2, 2))
    c = 1
    for i in 1:(2 * n)
        for j in (i + 1):(2 * n)
            table[c, :] .= [xf[i], xf[j]]
            c += 1
        end
    end

    h = hash % (nc2) + 1
    return table[h, 1] + table[h, 2]
end

function perlin3d(x::T, y::T, z::T) where {T<:AbstractFloat}
    xi = trunc(Int, x) & 255 + 1
    yi = trunc(Int, y) & 255 + 1
    zi = trunc(Int, z) & 255 + 1

    xf = first(modf(x))
    yf = first(modf(y))
    zf = first(modf(z))

    u = fade(xf)
    v = fade(yf)
    w = fade(zf)

    aaa = PERMS[PERMS[PERMS[xi] + yi] + zi]
    aba = PERMS[PERMS[PERMS[xi] + yi + 1] + zi]
    aab = PERMS[PERMS[PERMS[xi] + yi] + zi + 1]
    abb = PERMS[PERMS[PERMS[xi] + yi + 1] + zi + 1]
    baa = PERMS[PERMS[PERMS[xi + 1] + yi] + zi]
    bba = PERMS[PERMS[PERMS[xi + 1] + yi + 1] + zi]
    bab = PERMS[PERMS[PERMS[xi + 1] + yi] + zi + 1]
    bbb = PERMS[PERMS[PERMS[xi + 1] + yi + 1] + zi + 1]

    x1 = lerp(gradient3d(aaa, xf, yf, zf), gradient3d(baa, xf - 1, yf, zf), u)
    x2 = lerp(gradient3d(aba, xf, yf - 1, zf), gradient3d(bba, xf - 1, yf - 1, zf), u)
    y1 = lerp(x1, x2, v)

    x1 = lerp(gradient3d(aab, xf, yf, zf - 1), gradient3d(bab, xf - 1, yf, zf - 1), u)
    x2 = lerp(gradient3d(abb, xf, yf - 1, zf - 1), gradient3d(bbb, xf - 1, yf - 1, zf - 1), u)
    y2 = lerp(x1, x2, v)

    return (lerp(y1, y2, w) + 1) / 2
end

function perlin(x::T...) where {T<:AbstractFloat}
    n = length(x)
    xi = trunc.(Int, x) .& 255 .+ 1
    xf = first.(modf.(x))
    u = fade.(xf)

    hypv = Iterators.product(ntuple(Returns(1:2), n)...)
    inds = zeros(Int, size(hypv))
    grads = Array{T,n}(undef, size(hypv))
    for v in hypv
        for (c, i) in zip(v, xi)
            inds[v...] = PERMS[inds[v...] + i + c - 1]
        end
        grads[v...] = gradient(inds[v...], (xf .- v .+ 1)...)
    end

    for dm in (n - 1):-1:0
        inds_after = ntuple(Returns(:), dm)
        grads =
            lerp.(
                grads[1, inds_after...], grads[2, inds_after...], u[n - dm]
            )
    end

    return (grads + 1) / 2
end

"""
    perlin_fill(res, x)

Fills a hypercube (corners at `(0...)` and `(x...)`) with perlin noise.
`res` is a resolution (number of points per dimension).
"""

function perlin_fill(res::Int, x::T...) where {T<:AbstractFloat}
    n = length(x)

    idxs = Iterators.product(ntuple(Returns(1:res), n)...)
    hypv = Iterators.product(ntuple(Returns(1:2), n)...)
    inds = Array{Int,n}(undef, size(hypv))
    grads = Array{T,n + n}(undef, (size(idxs)..., size(hypv)...))
    us = Array{T,n + 1}(undef, (size(idxs)..., n))

    function local_perlin!(idx::Int...)
        xl = idx ./ res .* x
        xi = trunc.(Int, xl) .& 255 .+ 1
        xf = first.(modf.(xl))
        us[idx..., :] .= fade.(xf)

        inds .= zeros(Int, size(hypv))
        for v in hypv
            for (c, i) in zip(v, xi)
                inds[v...] = PERMS[inds[v...] + i + c - 1]
            end
            grads[idx..., v...] = gradient(inds[v...], (xf .- v .+ 1)...)
        end
    end

    map(idx -> local_perlin!(idx...), idxs)

    for dm in (n - 1):-1:0
        inds_before = ntuple(Returns(:), n)
        inds_after = ntuple(Returns(:), dm)
        grads =
            lerp.(
                grads[inds_before..., 1, inds_after...],
                grads[inds_before..., 2, inds_after...],
                us[inds_before..., n - dm],
            )
    end
    return (grads .+ 1) ./ 2
end

function octaveperlin3d(
    octaves::Int, persistence::T, x::T, y::T, z::T
) where {T<:AbstractFloat}
    total = zero(T)
    frequency = oneunit(T)
    amplitude = oneunit(T)
    maxval = zero(T)
    for _ in 1:octaves
        total += perlin3d(x * frequency, y * frequency, z * frequency) * amplitude
        maxval += amplitude
        amplitude *= persistence
        frequency *= 2
    end
    return total / maxval
end

function octaveperlin(octaves::Int, persistence::T, x::T...) where {T<:AbstractFloat}
    total = zero(T)
    frequency = oneunit(T)
    amplitude = oneunit(T)
    maxval = zero(T)
    for _ in 1:octaves
        total += perlin((x .* frequency)...) * amplitude
        maxval += amplitude
        amplitude *= persistence
        frequency *= 2
    end
    return total / maxval
end
