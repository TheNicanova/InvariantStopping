"""
    Sample

Abstract type representing a realization. 

!!! Note
The Sample object can be thought as a dictionary where the elements of the Schedule object are the keys and where the states are the items. One samples a random dictionary from schedule to state.

"""
abstract type Sample{S <: State, T <: Schedule} end


"""
    RootSample <: Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref) and a collection of [`Sample`](@ref). 
Each of the later is to be interpreted as happening at a later point in time.
"""
struct RootSample{S,T <: Schedule,N} <: Sample{S,T}
  state::S
  schedule::T
  underlying_model::UnderlyingModel
  children::NTuple{N, <: Sample}
end

"""
    NodeSample <: Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref) and a collection of [`Sample`](@ref). 
Each of the later is to be interpreted as happening at a later point in time.
"""
struct NodeSample{S,T <: Schedule, N} <: Sample{S,T}
  state::S
  schedule::T
  underlying_model::UnderlyingModel
  children::NTuple{N, <: Sample}
end


"""
    LeafSample <: Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref).
To be interpreted as the last piece of sample data along a schedule branch.
"""
struct LeafSample{S,T <: LeafSchedule} <: Sample{S,T}
  state::S
  schedule::T
  underlying_model::UnderlyingModel
end


"""
    RootSample(::NodeSample)

Wrapper constructor for [`RootSample`](@ref).
"""
RootSample(sample::NodeSample) = RootSample(sample.state, sample.schedule, sample.underlying_model, sample.children)


get_time(sample::Sample) = return get_time(sample.state)

get_coord(sample::Sample) = return get_coord(sample.state)



"""
    NodeSample(::State, ::LeafSchedule, ::UnderlyingModel)

Helper constructor.
"""
function NodeSample(initial::State, schedule::LeafSchedule, underlying_model::UnderlyingModel)
  sample = LeafSample(initial, schedule, underlying_model)
  return sample
end

"""
    NodeSample(::State, ::NodeSchedule, ::UnderlyingModel)

Helper constructor.
"""
function NodeSample(initial::State, schedule::NodeSchedule, underlying_model::UnderlyingModel)
  children = Tuple(Sample(forward_to(initial, child, underlying_model), child, underlying_model, policy_sample_dict) for child in schedule.children)
  sample = NodeSample(initial, schedule, underlying_model, children)
  return sample
end


"""
    Sample(::State, ::RootSchedule, ::UnderlyingModel)

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
function Sample(initial::State, schedule::RootSchedule, underlying_model::UnderlyingModel)
  return RootSample(NodeSample(initial, schedule, underlying_model))
end


"""
    Layer

An abstract type representing the collection of samples that happen at a shared [`StoppingPolicy`](@ref)
"""
abstract type Layer{S <: Sample} end

"""
   RootLayer <: Layer

Represents the first layer.
"""
struct RootLayer{S} <: Layer{S}
  stopping_policy::StoppingPolicy
  sample_list::Vector{S}
  next::Layer{S}
end

"""
   NodeLayer <: Layer

Represents an intermediate layer.
"""
struct NodeLayer{S} <: Layer{S}
  stopping_policy::StoppingPolicy
  sample_list::Vector{S}
  next::Layer{S}
end

"""
   LeafLayer <: Layer

Represents the last layer.
"""
struct LeafLayer{S} <: Layer{S}
  stopping_policy::StoppingPolicy
  sample_list::Vector{S}
end



"""
    LayeredSample <: Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref) and a list of [`Layer`](@ref)
To be interpreted as the first piece of sample data along a schedule branch.
"""
struct LayeredSample{S <: State, T <: Schedule} <: Sample{S,T}
  sample::RootSample{S, T}
  layers::Vector{<: Layer}
end


"""
    NodeSample(::State, ::LeafSchedule, ::UnderlyingModel, ::Any, ::Dict)

A helper constructor for [`LayeredSample`]
"""
function NodeSample(initial::State, schedule::LeafSchedule, underlying_model::UnderlyingModel, layers, dict)
  sample = LeafSample(initial, schedule, underlying_model)
  index = dict[schedule.stopping_policy].index
  push!(layers[index].sample_list, sample)
  return sample
end

"""
    NodeSample(::State, ::NodeSchedule, ::UnderlyingModel, ::Any, ::Dict)

A helper constructor for [`LayeredSample`]
"""
function NodeSample(initial::State, schedule::Schedule, underlying_model::UnderlyingModel, layers, dict)
  children = Tuple(NodeSample(forward_to(initial, child, underlying_model), child, underlying_model, layers, dict) for child in schedule.children)
  sample = NodeSample(initial, schedule, underlying_model, children)
  index = dict[schedule.stopping_policy].index
  push!(layers[index].sample_list, sample)
  return sample
end

"""
    Sample(::State, ::LayeredSchedule, ::UnderlyingModel)

Constructor for [`LayeredSample`](@ref).
Starting from the initial [`State`](@ref), it samples from the [`UnderlyingModel`](@ref) according to the [`Schedule`](@ref). It also builds a list of [`Layer`](@ref).

Examples
```julia
julia> initial_state = State(0.0, 4.5)

julia> schedule = Schedule(LinRange(0,10,5))

julia> underlying_model = GeometricBrownianMotion() # Default parameters

julia> sample = Sample(initial_state, schedule, underlying_model)
```
"""
function Sample(initial::State, layered_schedule::LayeredSchedule, underlying_model::UnderlyingModel)

  # Initialization of layers
  stopping_list = layered_schedule.stopping_list
  stopping_num = length(stopping_list)
  layers = Array{Layer}(undef, stopping_num)

  leaf_layer = LeafLayer(stopping_list[end],Vector{Sample}())
  layers[end] = leaf_layer

  next = leaf_layer
  for i in stopping_num-1:-1:2
    node_layer = NodeLayer(stopping_list[i], Vector{Sample}(), next)
    layers[i] = node_layer
    next = node_layer
  end

  root_layer = RootLayer(stopping_list[1], Vector{Sample}(), next)
  layers[1] = root_layer
  root_sample = RootSample(NodeSample(initial, layered_schedule.schedule, underlying_model, layers, layered_schedule.dict)) # populate layers
  return LayeredSample(root_sample, layers)
end

