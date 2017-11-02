# Unwrap

This is a Julia function for 1D, 2D, and 3D phase unwrapping code based on:
 * (2D) M. A. Herráez, D. R. Burton, M. J. Lalor, and M. A. Gdeisat, "Fast two-dimensional phase-unwrapping algorithm based on sorting by reliability following a noncontinuous path", `Applied Optics, Vol. 41, Issue 35, pp. 7437-7444 (2002) <http://dx.doi.org/10.1364/AO.41.007437>`_,
* (3D) H. Abdul-Rahman, M. Gdeisat, D. Burton, M. Lalor, "Fast three-dimensional phase-unwrapping algorithm based on sorting by reliability following a non-continuous path", `Proc. SPIE 5856, Optical Measurement Systems for Industrial Inspection IV, 32 (2005) <http://dx.doi.ogr/doi:10.1117/12.611415>`_.

More information about the code can be found on GERI homepage:
[2D](http://www.ljmu.ac.uk/GERI/90207.htm),
[3D](http://www.ljmu.ac.uk/GERI/90208.htm).

## Benchmarks

Two versions of unwrap have been implemented - A Julia version which calls the
C functions, and a pure Julia version. Only the pure Julia version is exported.

## Installation

Once complete, simply run `Pkg.add("Unwrap")`

## Usage

The interface consists of a single function, unwrap:

```julia
using Unwrap
unwrapped_array = unwrap(wrapped_array)
```

where `wrapped_array` is an `AbstractArray` of `Number`.

## Acknowledgments

Outside of the cited papers, interface and inspiration also taken from python's
phase-unwrap: <https://github.com/geggo/phase-unwrap>
