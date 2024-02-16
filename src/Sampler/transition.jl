module Transition

export forward
export BrownianMotion
export GeometricBrownianMotion
export ModuloTwo
export UnderlyingModel

export forward

using ..SimulationState
using Distributions



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

"""
    BrownianMotion
"""
struct BrownianMotion <: UnderlyingModel end



function forward(state::State{N,V}, now::T, later::T, underlying_model::GeometricBrownianMotion) where {N, T <: Number, V <: Number}
  if now > later
    throw(ArgumentError("Initial time is later than forward time."))
  elseif now == later
    return state
  else
    dt = later - now
    scaling_factor = exp((underlying_model.rate - underlying_model.dividend - underlying_model.sigma^2.0 / 2.0) * dt + underlying_model.sigma * sqrt(dt) * rand(Normal(0,1)))
    updated_coord = state.coord .* scaling_factor
    return State(updated_coord)
  end
end

function forward(state::State{1,V}, now::T, later::T, underlying_model::ModuloTwo) where {T <: Number,V <: Number}
  if 0 <= (later % 2) < 1
    return State{1,V}((0.0,))
  else
    return State{1,V}((1.0,))
  end
end

function forward(state::State{N,V}, now::T, later::T, underlying_model::BrownianMotion) where {T, V, N}
  if now > later
    throw(ArgumentError("Initial time is later than forward time."))
  end
  perturbation = Tuple(rand(Normal(0,1),N))
  scaling_factor = later - now
  new_coord = state.coord .+ (scaling_factor .* perturbation)
  return State{N,V}(new_coord)
end

end