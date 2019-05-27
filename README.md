# Unwrap

## Notice

This functionality has been moved into the [DSP.jl](https://github.com/JuliaDSP/DSP.jl) package. Please see the [DSP.jl documentation](https://juliadsp.github.io/DSP.jl/stable/util/) for changes to the function signature.

## Introduction

This is a pure Julia implementation for 1D, 2D, 3D and arbitrary-D phase unwrapping code based on:
 * (2D) M. A. Herráez, D. R. Burton, M. J. Lalor, and M. A. Gdeisat, "Fast two-dimensional phase-unwrapping algorithm based on sorting by reliability following a noncontinuous path", `Applied Optics, Vol. 41, Issue 35, pp. 7437-7444 (2002) <http://dx.doi.org/10.1364/AO.41.007437>`_,
* (3D) H. Abdul-Rahman, M. Gdeisat, D. Burton, M. Lalor, "Fast three-dimensional phase-unwrapping algorithm based on sorting by reliability following a non-continuous path", `Proc. SPIE 5856, Optical Measurement Systems for Industrial Inspection IV, 32 (2005) <http://dx.doi.ogr/doi:10.1117/12.611415>`_.

More information about the code can be found on [GERI homepage](https://www.ljmu.ac.uk/research/centres-and-institutes/faculty-of-engineering-and-technology-research-institute/geri/phase-unwrapping):

## Installation

Run `Pkg.clone("https://github.com/platawiec/Unwrap.jl")`.

## Usage

The interface consists of a single function, unwrap:

```julia
using Unwrap
unwrapped_array = unwrap(wrapped_array)
```

where `wrapped_array` is an `AbstractArray`. There is also an
in-place version, `unwrap!(A)` which mutates `A`. The returned array will have
the same precision as `A` (i.e. `BigFloat`, `Float32`, etc. work). Type
`?unwrap` for more.

1D, 2D, and 3D unwrapping are all supported, as well as arbitrary dimensions, for whatever reason.

## See Also

The package [DSP.jl](https://github.com/JuliaDSP/DSP.jl) provides the one-dimensional version of `unwrap!` and `unwrap`. This package will live and be maintained in the JuliaDSP ecosystem.

## Acknowledgments

Outside of the cited papers, interface and inspiration also taken from python's
phase-unwrap: <https://github.com/geggo/phase-unwrap>
