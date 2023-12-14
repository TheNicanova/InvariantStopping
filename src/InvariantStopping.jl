module InvariantStopping

using Distributions

include("Sampler/state.jl")

include("Sampler/stopping_time.jl")

include("Sampler/schedule.jl")

include("Sampler/lowered_schedule.jl")

include("Sampler/underlying_model.jl")

include("Sampler/sample.jl")

#include("plot.jl")


# Fix the Union{Nothing, ...} so we can write the constructor sample(initial, underlying_model, schedule)::Sample
# initial time needs to agree with schedule time. Perhaps have a rootsample, rootschedule.

export State

export StoppingTime

export DeterministicStopping
export StoppingTime

export Schedule
export LeafSchedule
export NodeSchedule
export RootSchedule
export Star
export Tree

export UnderlyingModel
export GeometricBrownianMotion

export Sample
export LeafSample
export NodeSample
export RootSample

export plot

export forward_to


"""
    forward_to(::State, ::Number, ::UnderlyingModel)

Forwards a (`State`)(@ref) in time using the provided ()`UnderlyingModel`](@ref). Returns a (`State`)(@ref).

Examples
```julia
julia> initial_state = State(0.0,1.0)

julia> forward_time = 10.0

julia> underlying_model = GeometricBrownianMotion()

julia> forward_state = forward_to(initial_state, forward_time, underlying_model)

```
"""
function forward_to(initial::State{N,T,V}, forward::T, underlying_model::GeometricBrownianMotion) where {N, T <: Number, V <: Number}
  dt = forward - get_time(initial)
  if dt < 0
    throw(ArgumentError("Initial time is later than forward time."))
  end

  scaling_factor = exp((underlying_model.rate - underlying_model.dividend - underlying_model.sigma^2.0 / 2.0) * dt + underlying_model.sigma * sqrt(dt) * rand(Normal(0,1)))
  updated_coord = get_coord(initial) .* scaling_factor
  return State(forward, updated_coord)
end

function forward_to(initial::State, forward_schedule::Schedule, underlying_model::UnderlyingModel)
  return forward_to(initial, get_time(forward_schedule), underlying_model)
end

end


#function price(sample::Sample, pricing_model::PricingModel, option::Option) end