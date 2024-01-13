# A schedule object that is meant to serve the sampler.

struct LoweredSchedule{T}
  stopping_time::StoppingTime{T}
  time_list::Vector{T}
  children::Vector{LoweredSchedule{T}}
end


function lower(schedule::Schedule)
    return lower_schedule_helper(schedule, -Inf)[1] # Setting the "earliest parent" to -Inf, and returning an only object
end

"""
Each LoweredSchedule object contains the sampling events (timestamps, etc.) 
from: the earliest stopped time of the parent schedule 
to: the last stopped time of the schedule.
"""

"""
Lower schedule helper returns a LoweredSchedule object paired with a full list of timestamps.
"""
function lower_helper(schedule::Schedule, parent_earliest_stopping_opportunity)

  time_list = get_time_list(schedule.stopping_time) # time list inside the contained stopping time

  if length(schedule.children) == 0 # Leaf
    return LoweredSchedule(schedule.stopping_time, time_list, []) # A leaf schedule is in charge of its time_list as there is no one else left.
  else
  
  pairs_list = [lower_schedule_helper(child, self_earliest_stopped_time) for child in schedule.children] 
  children = [pair[1] for pair in pairs_list]
  children_time_list = [pair[2] for pair in pairs_list]

  full_time_list = union(children_time_list..., time_list)

  # Each LoweredSchedule object contains the times from the earliest stopping opportunity of the parent schedule to the last stopping opportunity of this schedule.
  truncated_time_list = sort!(filter(x -> get_earliest_stopping_opportunity(schedule.stopping_time) < x.time  <= self_time_list[end], full_time_list))

  return LoweredSchedule(schedule.stopping_time, truncated_time_list, children), full_time_list
  end
end
