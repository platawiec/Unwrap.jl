A_unwrapped = collect(linspace(0, 10π, 100))
A_wrapped = A_unwrapped .% (2π)

@test unwrap(A_wrapped) == A_unwrapped

# test in-place version
unwrap!(A_wrapped)
@test A_wrapped == A_unwrapped

A_bf_uw = collect(linspace(0, 10*BigFloat(π), 100))
A_bf_w = A_bf_uw .% (2*BigFloat(π))
@test unwrap(A_bf_w) ≈ A_bf_uw

A_f32_uw = collect(linspace(0, 10*Float32(π), 100))
A_f32_w = A_bf_uw .% (2*Float32(π))
@test unwrap(A_bf_w) ≈ A_bf_uw
