
"""
    Schedule

An abstract type representing partial orders over [`StoppingTime`](@ref). Each schedule stores a [`StoppingTime`](@ref). 

"""
abstract type Schedule{T <: StoppingTime} end



"""
    RootSchedule <: Schedule

    Stores a collection of [`Schedule`](@ref) chidlren, doesn't have a parent.
"""
struct RootSchedule{T<:DeterministicStopping, N} <: Schedule{T}
  stopping_time::T
  children::NTuple{N, <: Schedule}
end


"""
    NodeSchedule <: Schedule

    Stores a collection of [`Schedule`](@ref) chidlren and a [`Schedule`](@ref) parent.
"""
struct NodeSchedule{T,N} <: Schedule{T}
  stopping_time::T
  children::NTuple{N, <: Schedule}
end

"""
    LeafSchedule <: Schedule

    Stores a [`Schedule`](@ref) parent, doesn't have children.
"""
struct LeafSchedule{T} <: Schedule{T} 
  stopping_time::T
end

LeafSchedule(stopping_time::T) where {T} = LeafSchedule(stopping_time, EmptyTime{T}())



"""
    LayeredSchedule <: Schedule
This type represents a [`Schedule`](@ref) that is a total order (a special case of a partial order). 
It is a container containing the Schedule as well as a vector of policy-count pairs, sorted from ealiest to latest.
"""
struct LayeredSchedule{T<:StoppingTime} <: Schedule{T}
  schedule::RootSchedule{T}
  stopping_list::Vector{<:StoppingTime}
  dict::Dict{<:StoppingTime, <: NamedTuple{(:index, :count), Tuple{Int, Int}}}
end

get_time(schedule::Schedule{<: DeterministicStopping}) = return schedule.stopping_time.time

get_policy(schedule::Schedule) = schedule.stopping_time

get_children(schedule::NodeSchedule) = return schedule.children


"""
    NodeSchedule(::LinRange, ::Integer)

Constructor for [`NodeSchedule`](@ref). Creates a schedule representing a tree of trajectories with a prescribed branching factor.
Can be considered as a helper method for the [`Schedule`] constructors.
"""
function NodeSchedule(lin::LinRange{<:Number,<:Integer}, branching_factor::Integer)
  if length(lin) == 1
    return LeafSchedule(DeterministicStopping(lin[1]))
  else
    return NodeSchedule(DeterministicStopping(lin[1]), Tuple(NodeSchedule(lin[2:end], branching_factor) for _ in 1:branching_factor))
  end
end

"""
    NodeSchedule(::LinRange)

Wrapper constructor for [`NodeSchedule`](@ref). Creates a schedule representing a trajectory that stops at times given by the argument. Can be considered as a helper method for the [`Schedule`] constructors.

"""

function NodeSchedule(lin::LinRange{<:Number,<:Integer})
  return NodeSchedule(lin, 1)
end

"""
    RootSchedule(::NodeSchedule)  

Wrapper constructor for [`RootSchedule`](@ref). 
"""
RootSchedule(lin::LinRange{<:Number,<:Integer}, branching_factor::Integer) = RootSchedule(NodeSchedule(lin, branching_factor))

"""
    RootSchedule(::NodeSchedule)  

Wrapper constructor for [`RootSchedule`](@ref). 
"""
RootSchedule(node_schedule::NodeSchedule) = RootSchedule(node_schedule.stopping_time, node_schedule.children)


"""
    RootSchedule(::NodeSchedule)  

Wrapper constructor for [`RootSchedule`](@ref).
"""
RootSchedule(lin::LinRange{<:Number,<:Integer}) = RootSchedule(NodeSchedule(lin))



"""
    Tree(::LinRange, ::Integer)


Constructor for [`LayeredSchedule`](@ref). Creates a schedule representing a tree of trajectories with a prescribed branching factor.
Examples:
```julia
julia> schedule = Tree(LinRange(0,10,11),2)

```
"""
function Tree(lin::LinRange{<:Number,<:Integer}, branching_factor::Integer)

  root_schedule = RootSchedule(lin, branching_factor)
  stopping_list = [DeterministicStopping(t) for t in lin] 
  dict = Dict(DeterministicStopping(lin[i]) => (index=i, count=branching_factor^i) for i in eachindex(lin))

  return LayeredSchedule(root_schedule, stopping_list, dict) 
end

"""
    Schedule(::LinRange)

Wrapper constructor for [`LayeredSchedule`](@ref).

Examples
```julia
julia> schedule = Schedule(LinRange(0,10,11))
```
  
"""
function Schedule(lin::LinRange{<:Number,<:Integer})
  return Tree(lin, 1)
end


"""
    Star(::LinRange, Integer)
Constructor for a [`LayeredSchedule`](@ref) where the schedule branches once at the beginning and the generated branches never branch out again.
"""
function Star(lin::LinRange{<:Number,<:Integer}, branching_factor::Integer)
  root_schedule = RootSchedule(DeterministicStopping(lin[1]), Tuple( NodeSchedule(lin[2:end]) for _ in 1:branching_factor))
  
  stopping_list = [DeterministicStopping(t) for t in lin]
  dict = Dict{StoppingTime, NamedTuple{(:index, :count), Tuple{Int64, Int64}}}()
  dict[DeterministicStopping(lin[1])] = (index = 1, count=1)
  for i in eachindex(lin[2:end])
    dict[DeterministicStopping(lin[i])] = (index = i, count=branching_factor)
  end

  return LayeredSchedule(root_schedule, stopping_list, dict)
end




###############

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

An abstract type representing the collection of samples that happen at a shared [`StoppingTime`](@ref)
"""
abstract type Layer{S <: Sample} end

"""
   RootLayer <: Layer

Represents the first layer.
"""
struct RootLayer{S} <: Layer{S}
  stopping_time::StoppingTime
  sample_list::Vector{S}
  next::Layer{S}
end

"""
   NodeLayer <: Layer

Represents an intermediate layer.
"""
struct NodeLayer{S} <: Layer{S}
  stopping_time::StoppingTime
  sample_list::Vector{S}
  next::Layer{S}
end

"""
   LeafLayer <: Layer

Represents the last layer.
"""
struct LeafLayer{S} <: Layer{S}
  stopping_time::StoppingTime
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
  index = dict[schedule.stopping_time].index
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
  index = dict[schedule.stopping_time].index
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

