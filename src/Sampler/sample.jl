# A schedule object that is meant to serve the sampler.

# LoweredSchedule is meant to service the sampler


struct LoweredSchedule{T}
  stopping_time::StoppingTime{T}
  timeline::Vector{T}
  children::Vector{LoweredSchedule{T}}
  timeline_index_of_stopping_opportunity::Vector{<:Integer}
end


function lower(schedule::Schedule)
    return lower_helper(schedule, -Inf)[1] # Setting the "earliest parent" to -Inf, and returning an only object
end

"""
Each LoweredSchedule object contains the sampling events (timestamps, etc.) 
from: the earliest stopped time of the parent schedule 
to: the last stopped time of the schedule.
"""

"""
Lower schedule helper returns a LoweredSchedule object paired with a full list of timestamps.
"""
function lower_helper(schedule::Schedule{StoppingTime{T}}, parent_earliest_stopping_opportunity) where {T}

  stopping_time_timestamp_list = timestamp(schedule.stopping_time) # timestamps inside the current stopping time

  endtimestamp_list = [x.timestamp_list[end] for x in schedule.stopping_time.stopping_opportunity_list] # Recall that each stopping opportunity is associated to the last timestamp it contains.

  if isempty(schedule.children) # Leaf
    timeline_index_of_stopping_opportunity = findall(timestamp -> timestamp ∈ endtimestamp_list, stopping_time_timestamp_list)
    return (LoweredSchedule(schedule.stopping_time, stopping_time_timestamp_list, LoweredSchedule{T}[], timeline_index_of_stopping_opportunity), stopping_time_timestamp_list) # A leaf schedule is in charge of its time_list as there is no one else left.
  else
  
  # Sending to children this stopping time's earliest stopping opportunity time
  pairs_list = [lower_helper(child, endtimestamp_list[1]) for child in schedule.children] 

  # collecting 
  children = [pair[1] for pair in pairs_list]
  children_timestamp_list = [pair[2] for pair in pairs_list]

  full_timestamp_list = union(children_timestamp_list..., stopping_time_timestamp_list)
  

  # Each LoweredSchedule object contains the times from the earliest stopping opportunity of the parent schedule to the last stopping opportunity of this schedule.
  truncated_timestamp_list = sort!(filter(time -> parent_earliest_stopping_opportunity <= time  <= endtimestamp_list[end], full_timestamp_list)) # [parent_earliest_stopping_opportunity, se]
  
  # timeline_index_of_stopping_opportunity will become the target timelines
  timeline_index_of_stopping_opportunity = findall(x -> x ∈ endtimestamp_list, truncated_timestamp_list) # we use the truncated timelist
  return (LoweredSchedule(schedule.stopping_time, truncated_timestamp_list, children, timeline_index_of_stopping_opportunity), full_timestamp_list)
  end
end

##### Sampler

"""
    LoweredSample

This type stores the basic unit of sampling events.
"""
struct LoweredSample{S <: State}
  state::S
  parent::Union{Nothing, LoweredSample{S}}
end



"""
    NodeSample <: Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref) and a collection of [`Sample`](@ref). 
Each of the later is to be interpreted as happening at a later point in time.
"""
mutable struct Sample{S <: State, T <: Number}
  state::S
  stopping_time::StoppingTime{T}
  underlying_model::UnderlyingModel
  children::Union{Nothing, Vector{Sample}}
  parent::Union{Nothing, Sample}
  lowered_sample::LoweredSample{S}
  stopping_time_index_of_first_stopped::Int
end





function sample(initial_state::State, schedule::Schedule, underlying_model::UnderlyingModel)

  if initial_state.time > schedule.stopping_time[1].timelist[1]
    error("Initial state after earliest timestamp.")
  end
  # Constructing the initial sample 
  initial_stopping_time = DeterministicTime(initial_state.time)
  initial_schedule = Schedule(initial_stopping_time, [schedule])
  initial_lowered_schedule = lower(initial_schedule)
  initial_lowered_sample = LoweredSample(initial_state, nothing)
  
  initial_sample = Sample(initial_state, initial_stopping_time, underlying_model, [], nothing, initial_lowered_sample, 1)

  initial_sample.children = [sample_helper(initial_sample, child, underlying_model) for child in initial_lowered_schedule.children]
  return initial_sample
end


"""
sample_helper is recursive.
at the beginning of the call, it locates the parent's index inside the lowered_schedule's timeline
next, it finds the target index, which is the index corresponding to the next-stopping_opportunity's last timestamp.
It chains the first sampled lowered_sample to the parent, then it recursively chain the lowered_sample until the current index is equal to the target index.
It then fetch the required timestamps, and evaluate the condition. 
Depending on the answer, it either 
  True :  creates a sample object, and branches into the children, then finish initialization of sample object
  False : continue the loop.
"""

function sample_helper(parent::Sample, lowered_schedule::LoweredSchedule, underlying_model)

  target_index_list = lowered_schedule.timeline_index_of_stopping_opportunity

  current_index = findfirst(x->x==parent.state.time, lowered_schedule.timeline)

  current_lowered_sample = parent.lowered_sample

  current_stopping_opportunity_index = 1

  for target_index in target_index_list

    if current_index > target_index
      error("target_index is smaller than the current index.")
    end

    while(current_index != target_index)
      new_state = forward(current_lowered_sample.state, timeline[target_index], underlying_model)
      new_lowered_sample = LoweredSample(new_state, current_lowered_sample)

      current_index += 1
      current_lowered_sample = new_lowered_sample
    end

    # After the loop we have the condition that current_index == target_index, we have reached the stopping opportunity's last timestamp.
    current_stopping_opportunity = lowered_schedule.stopping_time.stopping_opportunity_list[current_stopping_opportunity_index]
    state_list = find(current_stopping_opportunity.timestamp_list, current_lowered_sample)

    if current_stopping_opportunity.predicate(state_list)

      # Init this_sample with no children
      this_sample = Sample(current_lowered_sample.state, lowered_schedule.stopping_time, underlying_model, [], parent, current_lowered_sample, current_stopping_opportunity_index) 
      if isempty(lowered_schedule.children) # Leaf
        return this_sample
      end
      # Recursively get the children
      this_sample.children = [sample_helper(this_sample, child, underlying_model) for child in lowered_schedule.children]
      return this_sample
    end

    current_stopping_opportunity_index += 1
  end
  # if we haven't stopped, we return nothing
  return nothing 
end

function find(timestamp_list, lowered_sample::LoweredSample)
  state_list = []
  current_lowered_sample = lowered_sample
  for timestamp in reverse(timestamp_list)
    while timestamp != current_lowered_sample.state.time
      if isnothing(current_lowered_sample.parent)
        error("Can't find the timestamp ")
      end
      current_lowered_sample = current_lowered_sample.parent
    end
    push!(state_list, current_lowered_sample.state)
  end
  return reverse!(state_list)
end
