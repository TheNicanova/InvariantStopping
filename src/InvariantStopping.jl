module InvariantStopping

using Distributions

include("Sampler/sample.jl")

include("plot.jl")


# Fix the Union{Nothing, ...} so we can write the constructor sample(initial, underlying_model, schedule)::Sample
# initial time needs to agree with schedule time. Perhaps have a rootsample, rootschedule.

export State

export UnderlyingModel
export GeometricBrownianMotion
export ModuloTwo
export BrownianMotion

export StoppingOpportunity
export StoppingTime
export DeterministicTime
export timestamp
export HittingTime

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
export LoweredSample
export sample


export plot
export plot2D

export forward_to

export history
export lower_history
export trajectory_list
export leaf_list



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

#function price(sample::Sample, pricing_model::PricingModel, option::Option) end

# Returns the trajectory from root to sample at the highest level.
function history(sample::S) where {S}
  sample_list = S[sample]

  current_sample = sample
  while !isnothing(current_sample.parent)
    push!(sample_list, current_sample.parent)
    current_sample = current_sample.parent
  end
  return reverse!(sample_list)
end



# Returns the trajectory from root to sample at the lowest level.
function lower_history(sample::T) where {T} 
  return history(sample.lowered_sample)
end

function leaf_list(sample)
  if isempty(sample.children) || isnothing(sample.children)
    return [sample]
  else
    return union([leaf_list(child) for child in sample.children]...)
  end
end

function trajectory_list(sample)
  trajectory_list = []
  list = leaf_list(sample)

  for leaf in list
    push!(trajectory_list, history(leaf))
  end
  return trajectory_list
end
 
function children(sample) 

end

function parent(sample) end

function get_time(sample) end

function get_stopping_time(sample) end

function get_schedule(sample) end

function get_underlying_model(sample) end

function get_coord(sample_list)
   return [sample.state.coord for sample in sample_list]
end

function find(time, sample) end

# Find all the nodes with given time in sample. Returns a vector of samples.
function find(time_list::Vector, sample) end


function get_children_time(sample) end

function get_children_coord(sample) end

end


