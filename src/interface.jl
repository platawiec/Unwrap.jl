"""
    unwrap(A[, wrap_around, seed])

Unwraps the values in A modulo 2π, where A is a 1-, 2-, or 3- dimensional array.

# Arguments
- `A::AbstractArray{T, N}`: Array to unwrap
- `wrap_around::Tuple{Bool}`:  When an element of this tuple is `true`, the
    unwrapping process will consider the edges along the corresponding axis
    of the image to be connected
- `seed::Int`: Unwrapping of 2D or 3D images uses a random initialization. This
    sets the seed of the RNG.
"""
unwrap

"""
    unwrap!(A[, wrap_around, seed])

In-place version of unwrap.
"""
unwrap!

function unwrap{T, N}(A::AbstractArray{T, N},
                wrap_around::NTuple{N, Bool}=tuple(zeros(Bool, N)...),
                seed::Int=-1)
    A_copy = copy(A)
    unwrap!(A_copy, wrap_around, seed)
    return A_copy
end
