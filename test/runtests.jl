using Unwrap
using Base.Test

@time @testset "Unwrap 1D" begin include("test_unwrap_1D.jl") end
@time @testset "Unwrap 2D" begin include("test_unwrap_2D.jl") end
@time @testset "Unwrap 3D" begin include("test_unwrap_3D.jl") end
