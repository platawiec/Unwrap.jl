vec_unwrapped = linspace(0, 10π, 100)
mat_unwrapped = vec_unwrapped .+ vec_unwrapped'
mat_wrapped = mat_unwrapped .% (2π)

@test unwrap(mat_wrapped) == mat_unwrapped

# test in-place version
unwrap!(mat_wrapped)
@test mat_wrapped == mat_unwrapped
