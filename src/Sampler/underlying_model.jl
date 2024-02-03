"""
    UnderlyingModel

An abstract type representing the transition function of a markov process.
"""
abstract type UnderlyingModel end

"""
    GeometricBrownianMotion <: UnderlyingModel

A geometric Brownian motion, specified by its rate, standard deviation sigma and dividend.

```julia
julia> underlying_model = GeometricBrownianMotion(3.1,2.0,0.0)
```
"""
struct GeometricBrownianMotion <: UnderlyingModel
  rate::Number
  sigma::Number
  dividend::Number
end

struct ModuloTwo <: UnderlyingModel end