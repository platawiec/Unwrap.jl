A_unwrapped = collect(linspace(0, 10π, 100))
@. A_wrapped = A_unwrapped % (2π)

@assert unwrap(A_wrapped) == A_unwrapped

# test in-place version
unwrap!(A_wrapped)
@assert A_wrapped == A_unwrapped
