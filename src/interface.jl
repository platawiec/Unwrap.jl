"""
    unwrap(A[, wrap_around, seed])

Unwraps the values in A modulo 2π, where A is a 1-, 2-, or 3- dimensional array.

# Arguments
- `A::AbstractArray{T, N}`: Array to unwrap
- `wrap_around::Vector{Bool}`:  When an element of this vector is `true`, the
    unwrapping process will consider the edges along the corresponding axis
    of the image to be connected
- `seed::Int`: Unwrapping of 2D or 3D images uses a random initialization. This
    sets the seed of the RNG.
"""
function unwrap(A, seed::Int=-1)
    A_copy = copy(A)
    unwrap!(A_copy, seed)
    return A_copy
end

"""
    unwrap!(A[, wrap_around, seed])

In-place version of unwrap.
"""
unwrap!
