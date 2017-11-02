function unwrap(A)
    A_copy = copy(A)
    unwrap!(A_copy)
    return A_copy
end
