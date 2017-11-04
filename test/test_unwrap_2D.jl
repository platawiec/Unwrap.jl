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

# Test BigFloat
vec_bf = linspace(0, 5*BigFloat(π), 20)
mat_bf_uw = vec_bf .+ vec_bf'
mat_bf_w = mat_bf_uw .% (2*BigFloat(π))
uw_bf_test = unwrap(mat_bf_w)
difference = mat_bf_uw[1,1] - uw_bf_test[1,1]
@test eltype(uw_bf_test) == BigFloat
@test (uw_bf_test + difference) ≈ mat_bf_uw

# Test Float32
vec_f32 = linspace(0, 5*Float32(π), 20)
mat_f32_uw = vec_f32 .+ vec_f32'
mat_f32_w = mat_f32_uw .% (2*Float32(π))
uw_f32_test = unwrap(mat_f32_w)
difference = mat_f32_uw[1,1] - uw_f32_test[1,1]
@test eltype(uw_f32_test) == Float32
@test (uw_f32_test + difference) ≈ mat_f32_uw
