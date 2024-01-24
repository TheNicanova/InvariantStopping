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

export UnderlyingModel
export GeometricBrownianMotion

export StoppingOpportunity
export StoppingTime
export DeterministicTime
export timestamp

export Schedule
export LeafSchedule
export NodeSchedule
export RootSchedule
export Star
export Tree


export Schedule


export lower
export LoweredSchedule
export Sample
export sample

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
function forward(state::State{N,V}, now::T, later::T, underlying_model::GeometricBrownianMotion) where {N, T <: Number, V <: Number}
  if now > later
    throw(ArgumentError("Initial time is later than forward time."))
  elseif now == later
    return state
  else
    scaling_factor = exp((underlying_model.rate - underlying_model.dividend - underlying_model.sigma^2.0 / 2.0) * dt + underlying_model.sigma * sqrt(dt) * rand(Normal(0,1)))
    updated_coord = state.coord .* scaling_factor
    return State(updated_coord)
  end
end

#function price(sample::Sample, pricing_model::PricingModel, option::Option) end

# Returns the trajectory from root to sample at the highest level.
function trajectory(sample) end

# Returns the trajectory from root to sample at the lowest level.
function trace(sample) end
 
function children(sample) end

function parent(sample) end

function get_time(sample) end

function get_stopping_time(sample) end

function get_schedule(sample) end

function get_underlying_model(sample) end

function get_coord(sample) end

function find(time, sample) end

# Find all the nodes with given time in sample. Returns a vector of samples.
function find(time_list::Vector, sample) end

function get_coord(sample) end

function get_children_time(sample) end

function get_children_coord(sample) end

end