using Juno
using BenchmarkTools

f = (x,y) -> x^2 + y
x = linspace(0.0, 10.0, 500);
Auw = f.(x, x')
A = f.(x, x') .% (2π);
unwrap!(A, (false, false), 1234)
@btime unwrap!($A)
@code_warntype(unwrap!(A))
Juno.@profiler unwrap!(A)

a = 6rand()
b = 6rand()
@btime find_period($a, $b)

f = (x) -> x^2
x = linspace(0.0, 20.0, 1e6);
B = f.(x) .% (2π);
Juno.@profiler unwrap(B)
@btime unwrap!($B)
p1 = TestPixel(0.1)
p2 = TestPixel(0.2)
p3 = TestPixel(0.3)
p4 = TestPixel(0.4)
p5 = TestPixel(0.5)
p6 = TestPixel(0.6)
p7 = TestPixel(0.7)
p8 = TestPixel(0.8)
merge_pixels!(p1, p2, 1)
merge_pixels!(p1, p3, 0)
merge_pixels!(p4, p5, 0)
merge_pixels!(p6, p7, 0)
merge_into_group!(p5, p7, 0)
merge_into_group!(p2, p7, 0)
merge_pixels!(p1, p8, 0)

p8.head.last
