function unwrap(A, seed::Int=-1)
    A_copy = copy(A)
    unwrap!(A_copy, seed)
    return A_copy
end
