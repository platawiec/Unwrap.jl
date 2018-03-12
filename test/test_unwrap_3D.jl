Types = (Float32, Float64, BigFloat)
f(x, y, z) = 0.5x^2 - 0.1y^3 + z
f_wraparound2(x, y, z) = 5*sin(x) + 2*cos(y) + z
f_wraparound3(x, y, z) = 5*sin(x) + 2*cos(y) - 3*cos(z)
for T in Types
    grid = linspace(zero(T), 2π*one(T), 40)
    f_uw = f.(grid, grid', reshape(grid, 1, 1, :))
    f_wr = f_uw .% (2π)
    uw_test = unwrap(f_wr)
    difference = first(f_uw) - first(uw_test)
    @test isapprox(uw_test + difference, f_uw, atol=1e-8)
    # test in-place version
    unwrap!(f_wr)
    difference = first(f_uw) - first(f_wr)
    @test isapprox(f_wr + difference, f_uw, atol=1e-8)

    f_uw = f_wraparound2.(grid, grid', reshape(grid, 1, 1, :))
    f_wr = f_uw .% (2π)
    uw_test = unwrap(f_wr, (true, true, false))
    difference = first(f_uw) - first(uw_test)
    @test isapprox(uw_test + difference, f_uw, atol=1e-8)
    # test in-place version
    unwrap!(f_wr, (true, true, false))
    difference = first(f_uw) - first(f_wr)
    @test isapprox(f_wr + difference, f_uw, atol=1e-8)

    f_uw = f_wraparound3.(grid, grid', reshape(grid, 1, 1, :))
    f_wr = f_uw .% (2π)
    uw_test = unwrap(f_wr, (true, true, true))
    difference = first(f_uw) - first(uw_test)
    @test isapprox(uw_test + difference, f_uw, atol=1e-8)
    # test in-place version
    unwrap!(f_wr, (true, true, true))
    difference = first(f_uw) - first(f_wr)
    @test isapprox(f_wr + difference, f_uw, atol=1e-8)
end
