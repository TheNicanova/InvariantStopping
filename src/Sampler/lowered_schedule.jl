
import Base.collect

"""
    LoweredSchedule
"""
abstract type LoweredSchedule{T <: StoppingTime} end


"""
    TimeStamp

Semantically distinct from DeterministicTime, it is meant to indicate the fact that we need the value of a state at a given time as opposed to indicating we are stopping at that time.
"""
struct TimeStamp{T}
    time::T
end


function get_time_list(stopping_time::DeterministicTime) 
  return [stopping_time]
end

function get_time_list(stopping_opportunity::StoppingOpportunity)
  list = [TimeStamp(time) for time in stopping_opportunity.time_list] # List timestamps
  list = union{list, [stopping_opportunity]} # append the stopping opportunity and unique the result
  list = !sort(list, by = x -> x.time) # sort in place
  return list
end

function get_time_list(stopping_time::WaitingTime)
  list_of_list = [get_time_list(stopping_opportunity) for stopping_opportunity in stopping_time.stopping_opportunity_list]
  list = union(list_of_list...)
  list = !sort(list, by = x -> x.time)
  return list
end


"""
    RootSchedule <: Schedule

    Stores a collection of [`Schedule`](@ref) chidlren, doesn't have a parent.
"""
struct LoweredRootSchedule{T} <: LoweredSchedule{T}
  stopping_time::T
  time_list::Vector{Union{DeterministicTime{T}, StoppingOpportunity{T}, TimeStamp{T}}}
  children::Vector{<:LoweredSchedule}
end


"""
    NodeSchedule <: Schedule

    Stores a collection of [`Schedule`](@ref) chidlren and a [`Schedule`](@ref) parent.
"""
struct LoweredNodeSchedule{T} <: LoweredSchedule{T}
  stopping_time::T
  time_list::Vector{Union{DeterministicTime{T}, StoppingOpportunity{T}, TimeStamp{T}}}
  children::Vector{<:LoweredSchedule}
end

"""
    LeafSchedule <: Schedule

    Stores a [`Schedule`](@ref) parent, doesn't have children.
"""
struct LoweredLeafSchedule{T} <: LoweredSchedule{T} 
  stopping_time::T
  time_list::Vector{Union{DeterministicTime{T}, StoppingOpportunity{T}, TimeStamp{T}}}
end



function lower_schedule(schedule::Schedule)
  if length(schedule.children) == 0 # root is a leaf_layer
    error("The root node appears to have no children.")
  end
    node_schedule = lower_schedule_helper(schedule, -Inf)

    return LoweredRootSchedule(node_schedule.stopping_time, node_schedule.time_list, node_schedule.children)
end

function lower_schedule_helper(schedule::Schedule, parent_earliest_stopped_time)

  if length(schedule.children) == 0 # Leaf
    time_list = get_time_list(schedule.stopping_time)
    return LoweredLeafSchedule(schedule.stopping_time, time_list)
  else
    time_list = get_time_list(schedule.stopping_time) # time list inside the contained stopping time

    index_earliest = findfirst(x -> !(x isa TimeStamp), time_list) # the first non-timestamp object

    earliest_stopped_time = time_list[index_earliest].time
    latest_stopped_time = time_list[end].time

    children = [lower_schedule_helper(child, earliest_stopped_time) for child in schedule.children]
    tmp_list = union([child.time_list for child in children]...) # pulling all the time like objects from descendants
    tmp_list = filter(x -> x isa TimeStamp && x.time > parent_earliest_stopped_time && x.time <= latest_stopped_time, tmp_list) # keeping only this node's relevant timestamps.

    time_list = union(tmp_list, time_list)
    time_list = sort!(time_list, by = x -> x.time)

    return LoweredNodeSchedule(schedule.stopping_time, time_list, children)
  end
end
