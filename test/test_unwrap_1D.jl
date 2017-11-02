A_unwrapped = collect(linspace(0, 10π, 100))
@. A_wrapped = A_unwrapped % (2π)

@assert unwrap(A_wrapped) == A_unwrapped
