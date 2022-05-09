function fade(x::T) where {T<:AbstractFloat}
    return 6x^5 - 15x^4 + 10x^3
end


function smoothstep(a0::T, a1::T, x::T) where {T<:AbstractFloat}
    a0 != a1 || throw(ArgumentError("Arguments a0 and a1 cannot be equal"))
    x = clamp((x - a0) / (a1 - a0), 0.0, 1.0)
    return 3x^2 - 2x^3
end


function smootherstep(a0::T, a1::T, x::T) where {T<:AbstractFloat}
    a0 != a1 || throw(ArgumentError("Arguments a0 and a1 cannot be equal"))
    x = clamp((x - a0) / (a1 - a0), 0.0, 1.0)
    return fade(x)
end
