module Scheduler

export Schedule
export Star
export Tree

export lower
export LoweredSchedule

export get_sampling_event_list
export get_current_stopping_opportunity_index

using ..Policy

"""
  Schedule
  
Specifies a directed tree over stopping times.
"""
struct Schedule{T <: Number}
  stopping_time::StoppingTime{T}
  children
end

# constructors

Schedule(stopping_time::StoppingTime) = Schedule(stopping_time, [])


"""
  Tree

Constructs a tree of schedule with provided branching factor.
"""
function Tree(timestamp_list, branching_factor::Integer)

  stopping_policy = DeterministicTime(timestamp_list[1])

  if length(timestamp_list) == 1
    children = []
  else
    children = [Tree(timestamp_list[2:end], branching_factor) for _ in 1:branching_factor]
  end

  return Schedule(stopping_policy, children)
end

Schedule(timestamp_list) = Tree(timestamp_list,1)

"""
  Star

Constructs a tree where the branching factor is applied to the first timestamp only.
"""
function Star(timestamp_list, branching_factor::Integer)

  stopping_policy = DeterministicTime(timestamp_list[1])
  children = [Schedule(timestamp_list[2:end]) for _ in 1:branching_factor]

  return Schedule(stopping_policy, children)
end

####################################################

# A schedule object that is meant to serve the sampler.

# LoweredSchedule is meant to service the sampler

# TODO: transform the user defined, for instance predicate = x -> true, into a normal form.


"""
    LoweredSchedule

A schedule like object that services the need of the sampler.
The timeline contains the sampling events (timestamps) from the earliest stopping opportunity of the parent schedule to the last stopping opportunity of the schedule.
"""
struct LoweredSchedule{T}
  stopping_time::StoppingTime{T}
  timeline::Vector{T}
  children::Vector{LoweredSchedule{T}}
end


"""
    lower((::Schedule))

Recursively build [lowered schedule](@ref LoweredSchedule) from the provided schedule.
"""
function lower(schedule::Schedule{T}) where {T}
    return lower_helper(schedule, T[])[1] # Setting parent_endtimestamp_list to empty list
end


function lower_helper(schedule::Schedule{T}, parent_endtimestamp_list) where {T}

  stopping_time_timestamp_list = get_all_timestamp(schedule.stopping_time) # timestamps inside the current stopping time
  if isempty(schedule.children) # Leaf
    full_timestamp_list = sort!(union(parent_endtimestamp_list, stopping_time_timestamp_list))
    return (LoweredSchedule(schedule.stopping_time, full_timestamp_list, LoweredSchedule{T}[]), full_timestamp_list) # A leaf schedule is in charge of its time_list as there is no one else left.
  else
  
  endtimestamp_list = [stopping_opportunity.timestamp_list[end] for stopping_opportunity in schedule.stopping_time.stopping_opportunity_list]
  # Sending to children this stopping time's earliest stopping opportunity
  pairs_list = [lower_helper(child, endtimestamp_list) for child in schedule.children] 

  # collecting 
  children = [pair[1] for pair in pairs_list]
  children_timestamp_list = [pair[2] for pair in pairs_list]

  full_timestamp_list = union(parent_endtimestamp_list, stopping_time_timestamp_list,children_timestamp_list...) # if parent is empty, this is 
  
  if isempty(parent_endtimestamp_list)
    lower_bound = -Inf
  else
    lower_bound = parent_endtimestamp_list[1]
  end
  # Each LoweredSchedule object contains the times from the earliest stopping opportunity of the parent schedule to the last stopping opportunity of this schedule.
  truncated_timestamp_list = sort!(filter(time -> lower_bound <= time  <= endtimestamp_list[end], full_timestamp_list)) # [parent_earliest_stopping_opportunity, se]
  
  return (LoweredSchedule(schedule.stopping_time, truncated_timestamp_list, children), full_timestamp_list)
  end
end


# LoweredSchedule Interface

function get_sampling_event_list(current_timestamp::T, target_timestamp::T, lowered_schedule::LoweredSchedule{T}) where {T} # TODO: Make this more efficient.
  if current_timestamp > target_timestamp
    error("timestamps out of order")
  elseif current_timestamp < target_timestamp
    return [timestamp for timestamp in lowered_schedule.timeline if current_timestamp < timestamp <= target_timestamp] 
  elseif current_timestamp == target_timestamp
    return T[]
  end
end

function get_current_stopping_opportunity_index(current_timestamp::T, lowered_schedule::LoweredSchedule{T}) where {T}
  number_of_stopping_opportunity = length(lowered_schedule.stopping_time.stopping_opportunity_list)
  for index in 1:number_of_stopping_opportunity
    if lowered_schedule.stopping_time.stopping_opportunity_list[index].timestamp_list[end] >= current_timestamp
      return index
    end
  end
  error("if no stopping opportunity is >= current_timestamp, this means current_timestamp > latest stopping opportunity")
end

end