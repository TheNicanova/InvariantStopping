
"""
    Schedule

An abstract type representing partial orders over [`StoppingTime`](@ref). Each schedule stores a [`StoppingTime`](@ref). 
There are (3) types of schedules: 
  - [`RootSchedule`](@ref) 
  - [`NodeSchedule`](@ref)
  - [`LeafSchedule`](@ref)
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
