
"""
    Schedule

An abstract type representing partial orders over [`StoppingPolicy`](@ref).
"""
abstract type Schedule{T <: StoppingPolicy} end


"""
    NodeSchedule <: Schedule

This type stores a [`StoppingPolicy`](@ref) and a collection of [`Schedule`](@ref). 
Each of the later is to be interpreted as [`StoppingPolicy`](@ref) to happen at a later point in time.

Examples
```julia
julia> stopping_policy_1 = DeterministicStopping(3.0)

julia> stopping_policy_2 = DeterministicStopping(4.0)

julia> leaf = LeafSchedule(stopping_policy_2)

julia> node = NodeSchedule(stopping_policy_1, (leaf,leaf))

```

"""
struct NodeSchedule{N,T} <: Schedule{T}
  stopping_policy::T
  children::NTuple{N, <: Schedule}
end

"""
    LeafSchedule <: Schedule

This type stores a [`StoppingPolicy`](@ref). To be interpreted as the last [`StoppingPolicy`](@ref) to be followed.
"""
struct LeafSchedule{T} <: Schedule{T} 
  stopping_policy::T
end


get_time(schedule::Schedule{<: DeterministicStopping}) = return get_time(schedule.stopping_policy)

get_policy(schedule::Schedule) = schedule.stopping_policy

get_children(schedule::NodeSchedule) = return schedule.children



"""
    Schedule(::LinRange)

Constructor for [`Schedule`](@ref). Creates a schedule representing a trajectory that stops at times given by the argument.

Examples
```julia
julia> schedule = Schedule(LinRange(0,10,11))

```
  
"""
function Schedule(lin::LinRange{<:Number,<:Integer})
  reversed_lin = reverse(lin) # We construct the end of the object first and then work our way backward.
  next = nothing
  for t in reversed_lin
    if next === nothing
      next = LeafSchedule(DeterministicStopping(t))
    else
      next = NodeSchedule(DeterministicStopping(t), (next,))
    end
  end
  return next
end

"""
    Schedule(::LinRange, ::Integer)


Constructor for [`Schedule`](@ref). Creates a schedule representing a tree of trajectories with a prescribed branching factor.
Examples:
```julia
julia> schedule = Schedule(LinRange(0,10,11),2)

```
"""
function Schedule(lin::LinRange{<:Number,<:Integer}, branching_factor::Integer)
  reversed_lin = reverse(lin) # We construct the end of the object first and then work our way backward.
  next = nothing
  for t in reversed_lin
    if next === nothing
      next = LeafSchedule(DeterministicStopping(t))
    else
      next = NodeSchedule(DeterministicStopping(t), Tuple(next for _ in 1:branching_factor))
    end
  end
  return next
end

function Star(lin::LinRange{<:Number,<:Integer}, branching_factor::Integer)
  return NodeSchedule(DeterministicStopping(lin[1]), Tuple( Schedule(lin[2:end]) for _ in 1:branching_factor))
end

function Tree(lin::LinRange{<:Number,<:Integer}, branching_factor::Integer)
  return Schedule(lin, branching_factor)
end

#struct LinearSchedule{D,T} <: Schedule{T} where {D,T} end

#Struct TreeSchedule{B,D,T} <: Schedule{T} where {B,D,T} end

#TreeSchedule{B,1,T}(stopping_policy::T) =  LeafSchedule{T}(stopping_policy)

#TreeSchedule{B,D,T}(stopping_policy::T) where {B,D,T} 
