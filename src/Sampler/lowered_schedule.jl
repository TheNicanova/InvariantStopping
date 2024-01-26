# A schedule object that is meant to serve the sampler.

# LoweredSchedule is meant to service the sampler


struct LoweredSchedule{T}
  stopping_time::StoppingTime{T}
  timeline::Vector{T}
  children::Vector{LoweredSchedule{T}}
end


function lower(schedule::Schedule{T}) where {T}
    return lower_helper(schedule, T[])[1] # Setting the set of parents to emptyset
end

"""
Each LoweredSchedule object contains the sampling events (timestamps, etc.) 
from: the earliest stopped time of the parent schedule 
to: the last stopped time of the schedule.
"""

"""
Lower schedule helper returns a LoweredSchedule object paired with a full list of timestamps.
"""
function lower_helper(schedule::Schedule{T}, parent_endtimestamp_list) where {T}

  stopping_time_timestamp_list = timestamp(schedule.stopping_time) # timestamps inside the current stopping time
  
  if isempty(schedule.children) # Leaf
    return (LoweredSchedule(schedule.stopping_time, stopping_time_timestamp_list, LoweredSchedule{T}[]), stopping_time_timestamp_list) # A leaf schedule is in charge of its time_list as there is no one else left.
  else
  
  # Sending to children this stopping time's earliest stopping opportunity
  pairs_list = [lower_helper(child, endtimestamp_list) for child in schedule.children] 

  # collecting 
  children = [pair[1] for pair in pairs_list]
  children_timestamp_list = [pair[2] for pair in pairs_list]

  full_timestamp_list = union(parent_endtimestamp_list, stopping_time_timestamp_list,children_timestamp_list...) # if parent is empty, this is 
  
  # Each LoweredSchedule object contains the times from the earliest stopping opportunity of the parent schedule to the last stopping opportunity of this schedule.
  truncated_timestamp_list = sort!(filter(time -> parent_endtimestamp_list[1] <= time  <= endtimestamp_list[end], full_timestamp_list)) # [parent_earliest_stopping_opportunity, se]
  
  return (LoweredSchedule(schedule.stopping_time, truncated_timestamp_list, children), full_timestamp_list)
  end
end


# LoweredSchedule Interface


function get_sampling_event_list(current_timestamp::T, target_timestamp::T, lowered_schedule::LoweredSchedule{T}) where {T}# TODO: Make this more efficient.
  if current_timestamp == target_timestamp
    return T[]
  elseif current_timestamp < target_timestamp
    return [timestamp for timestamp in lowered_schedule.timeline if current_timestamp < timestamp <= target_timestamp] 
  else
    error("timestamps out of order")
  end
end

function get_stopping_opportunity_index(current_timestamp::T, lowered_schedule::LoweredSchedule{T}) where {T}
  number_of_stopping_opportunity = length(lowered_schedule.stopping_time.stopping_opportunity_list)
  for index in 1:number_of_stopping_opportunity
    if lowered_schedule.stopping_time.stopping_opportunity_list[index][end] >= current_timestamp
      return index
    end
  end
  error("if no stopping opportunity is >= current_timestamp, this means current_timestamp > latest stopping opportunity")
end