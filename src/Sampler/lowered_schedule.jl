# A schedule object that is meant to serve the sampler.

# LoweredSchedule is meant to service the sampler


struct LoweredSchedule{T}
  stopping_time::StoppingTime{T}
  timeline::Vector{T}
  children::Vector{LoweredSchedule{T}}
  timeline_index_of_stopping_opportunity::Vector{<:Integer}
end


function lower(schedule::Schedule)
    return lower_helper(schedule, [-Inf])[1] # Setting the "earliest parent" to -Inf, and returning an only object
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

  endtimestamp_list = [x.timestamp_list[end] for x in schedule.stopping_time.stopping_opportunity_list] # Recall that each stopping opportunity is associated to the last timestamp it contains.

  stopping_time_timestamp_list = timestamp(schedule.stopping_time) # timestamps inside the current stopping time
  
  if isempty(schedule.children) # Leaf
    timeline_index_of_stopping_opportunity = findall(timestamp -> timestamp ∈ endtimestamp_list, stopping_time_timestamp_list)
    return (LoweredSchedule(schedule.stopping_time, stopping_time_timestamp_list, LoweredSchedule{T}[], timeline_index_of_stopping_opportunity), stopping_time_timestamp_list) # A leaf schedule is in charge of its time_list as there is no one else left.
  else
  
  # Sending to children this stopping time's earliest stopping opportunity
  pairs_list = [lower_helper(child, endtimestamp_list[1]) for child in schedule.children] 

  # collecting 
  children = [pair[1] for pair in pairs_list]
  children_timestamp_list = [pair[2] for pair in pairs_list]

  full_timestamp_list = union(parent_endtimestamp_list, stopping_time_timestamp_list,children_timestamp_list...)
  

  # Each LoweredSchedule object contains the times from the earliest stopping opportunity of the parent schedule to the last stopping opportunity of this schedule.
  truncated_timestamp_list = sort!(filter(time -> parent_endtimestamp_list[1] <= time  <= endtimestamp_list[end], full_timestamp_list)) # [parent_earliest_stopping_opportunity, se]
  
  # timeline_index_of_stopping_opportunity will become the target timelines
  timeline_index_of_stopping_opportunity = findall(x -> x ∈ endtimestamp_list, truncated_timestamp_list) # we use the truncated timelist
  return (LoweredSchedule(schedule.stopping_time, truncated_timestamp_list, children, timeline_index_of_stopping_opportunity), full_timestamp_list)
  end
end


# LoweredSchedule Interface


function get_sampling_event_list(current_timestamp, target_timestamp, lowered_schedule) # TODO: Make this more efficient.
  if current_timestamp == target_timestamp
    return []
  elseif current_timestamp < target_timestamp
    return [timestamp for timestamp in lowered_schedule.timeline if current_timestamp < timestamp <= target_timestamp] 
  else
    error("timestamps out of order")
  end
end
