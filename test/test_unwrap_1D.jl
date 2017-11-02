A_unwrapped = collect(linspace(0, 10π, 100))
A_wrapped = A_unwrapped .% (2π)

@test unwrap(A_wrapped) == A_unwrapped

# test in-place version
unwrap!(A_wrapped)
@test A_wrapped == A_unwrapped
