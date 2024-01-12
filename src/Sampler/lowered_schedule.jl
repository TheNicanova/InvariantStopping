
import Base.collect

"""
    LoweredSchedule
"""
abstract type LoweredSchedule{S <: StoppingTime} end



function get_time_list(deterministic_time::DeterministicTime) 
  return [deterministic_time.time]
end

function get_time_list(stopping_opportunity::StoppingOpportunity)
  return stopping_opportunity.time_list
end

function get_time_list(stopping_time::WaitingTime)
  list_of_list = [get_time_list(stopping_opportunity) for stopping_opportunity in stopping_time.stopping_opportunity_list]
  list = union(list_of_list...) # the union will remove the duplicates if any
  list = !sort(list)
  return list
end

function get_earliest_stopping_opportunity(deterministic_time.DeterministicTime)
  return deterministic_time.time
end

function get_earliest_stopping_opportunity(stopping_opportunity::StoppingOpportunity)
  return stopping_opportunity.time_list[end]
end

function get_earliest_stopping_opportunity(stopping_time::WaitingTime)
  first_stopping_opportunity = stopping_time.stopping_opportunity_list[1]
  return get_earliest_stopping_opportunity(first_stopping_opportunity)
end


"""
    RootSchedule <: Schedule

    Stores a collection of [`Schedule`](@ref) chidlren, doesn't have a parent. 
    Each lowered schedule object is parametrized by the type of stopping time it contains.
"""
struct LoweredRootSchedule{S} <: LoweredSchedule{S}
  stopping_time::S
  time_list::Vector{<:Union{DeterministicTime, StoppingOpportunity, TimeStamp}}
  children::Vector{<:LoweredSchedule}
end


"""
    NodeSchedule <: Schedule

    Stores a collection of [`Schedule`](@ref) chidlren and a [`Schedule`](@ref) parent.
"""
struct LoweredNodeSchedule{S} <: LoweredSchedule{S}
  stopping_time::S
  time_list::Vector{<:Union{DeterministicTime, StoppingOpportunity, TimeStamp}}
  children::Vector{<:LoweredSchedule}
end 

"""
    LeafSchedule <: Schedule

    Stores a [`Schedule`](@ref) parent, doesn't have children.
"""
struct LoweredLeafSchedule{T} <: LoweredSchedule{T} 
  stopping_time::T
  time_list::Vector{<:Union{DeterministicTime, StoppingOpportunity, TimeStamp}}
end


function lower_schedule(schedule::Schedule)
  if length(schedule.children) == 0 # root is a leaf_layer
    error("The root node appears to have no children.")
  end
    node_schedule, time_list = lower_schedule_helper(schedule, -Inf) # Setting the "earliest parent" to -Inf

    return LoweredRootSchedule(node_schedule.stopping_time, node_schedule.time_list, node_schedule.children)
end

"""
Each LoweredSchedule object contains the sampling events (timestamps, etc.) 
from: the earliest stopped time of the parent schedule 
to: the last stopped time of the schedule.
"""

"""
Lower schedule helper returns a LoweredSchedule object paired with a full time list.
"""
function lower_schedule_helper(schedule::Schedule, parent_earliest_stopping_opportunity)

  time_list = get_time_list(schedule.stopping_time) # time list inside the contained stopping time

  if length(schedule.children) == 0 # Leaf
    return LoweredLeafSchedule(schedule.stopping_time, time_list) # A leaf schedule is in charge of its time_list as there is no one else left.
  else
  
  pairs_list = [lower_schedule_helper(child, self_earliest_stopped_time) for child in schedule.children] 
  children = [pair[1] for pair in pairs_list]
  children_time_list = [pair[2] for pair in pairs_list]

  full_time_list = union(children_time_list..., time_list)

  # Each LoweredSchedule object contains the times from the earliest stopping opportunity of the parent schedule to the last stopping opportunity of this schedule.
  truncated_time_list = sort!(filter(x -> get_earliest_stopping_opportunity(schedule.stopping_time) < x.time  <= self_time_list[end], full_time_list))

  return LoweredNodeSchedule(schedule.stopping_time, truncated_time_list, children), full_time_list
  end
end
