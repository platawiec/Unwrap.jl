vec_unwrapped = linspace(0, 5π, 20)
mat_unwrapped = vec_unwrapped .+ vec_unwrapped'
mat_wrapped = mat_unwrapped .% (2π)

uw_test = unwrap(mat_wrapped)
difference = mat_unwrapped[1,1] - uw_test[1,1]
@test (uw_test + difference) ≈ mat_unwrapped

# test in-place version
unwrap!(mat_wrapped)
difference = mat_unwrapped[1,1] - mat_wrapped[1,1]
@test (mat_wrapped + difference) ≈ mat_unwrapped
