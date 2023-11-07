"""
    Sample

Abstract type representing a realization.
"""
abstract type Sample{S <: State, T <: Schedule} end

"""
    NodeSample <: Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref) and a collection of [`Sample`](@ref). 
Each of the later is to be interpreted as happening at a later point in time.
"""
struct NodeSample{N,S,T <: NodeSchedule} <: Sample{S,T}
  state::S
  schedule::T
  underlying_model::UnderlyingModel
  children::NTuple{N, <: Sample}
end


"""
    Leaf <: Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref).
To be interpreted as the last piece of sample data along a schedule branch.
"""
struct LeafSample{S,T <: LeafSchedule} <: Sample{S,T}
  state::S
  schedule::T
  underlying_model::UnderlyingModel
end

get_time(sample::Sample) = return get_time(sample.state)

get_coord(sample::Sample) = return get_coord(sample.state)

"""
    Sample(::State, ::Schedule, ::UnderlyingModel)

Constructor for [`Sample`](@ref).
Starting from the initial [`State`](@ref), it samples from the [`UnderlyingModel`](@ref) according to the [`Schedule`](@ref).

Examples
```julia
julia> initial_state = State(0.0, 4.5)

julia> schedule = Schedule(LinRange(0,10,5))

julia> underlying_model = GeometricBrownianMotion() # Default parameters

julia> sample = Sample(initial_state, schedule, underlying_model)
```
"""
function Sample(initial::State, schedule::Schedule, underlying_model::UnderlyingModel) end

function Sample(initial::State, schedule::LeafSchedule, underlying_model::UnderlyingModel)
  return LeafSample(initial, schedule, underlying_model)
end


function Sample(initial::State, schedule::NodeSchedule, underlying_model::UnderlyingModel)
  # children
  children = Tuple(Sample(forward_to(initial, child, underlying_model), child, underlying_model) for child in get_children(schedule))
  return NodeSample(initial, schedule, underlying_model, children)
end

