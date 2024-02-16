
module Sampler

export find

export Sample
export LoweredSample

using ..SimulationState
using ..Policy
using ..Scheduler
using ..Transition
##### Sampler

"""
    LoweredSample

This type stores the basic unit of sampling events.
"""
struct LoweredSample{S <: State, T <: Number}
  state::S
  time::T
  parent::Union{Nothing,LoweredSample{S,T}}
end


# Lowered 

function find(timestamp_list, lowered_sample::LoweredSample{S,T}, parent, lowered_schedule) where {S <: State, T} # TODO: Make this more efficient, for instance search using the parent chain
  state_list = S[]
  current_lowered_sample = lowered_sample
  for timestamp in reverse(timestamp_list)
    while timestamp != current_lowered_sample.time
      if isnothing(current_lowered_sample.parent)
        error("Can't find the timestamp ")
      end
      current_lowered_sample = current_lowered_sample.parent
    end
    push!(state_list, current_lowered_sample.state)
  end
  return reverse!(state_list)
end


function forward(lowered_sample::LoweredSample{S,T}, stopping_opportunity::StoppingOpportunity{T}, lowered_schedule::LoweredSchedule{T}, underlying_model::UnderlyingModel) where {S <: State,T}

  target_timestamp = stopping_opportunity.timestamp_list[end]

  sampling_timestamp_list = get_sampling_event_list(lowered_sample.time, target_timestamp, lowered_schedule)
  
  current_lowered_sample = lowered_sample

    # Sample and chain lowered samples up to the target, if we are at target_timestamp already, this will do nothing
    for sampling_timestamp in sampling_timestamp_list
        new_state = Transition.forward(current_lowered_sample.state, current_lowered_sample.time, sampling_timestamp, underlying_model)
        new_lowered_sample = LoweredSample(new_state, sampling_timestamp, current_lowered_sample)
        current_lowered_sample = new_lowered_sample
    end
    return current_lowered_sample
end





"""
    Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref) and a collection of [`Sample`](@ref). 
Each of the later is to be interpreted as happening at a later point in time.
"""
mutable struct Sample{S <: State, T <: Number}
  state::S
  time::T
  stopping_time::StoppingTime{T}
  underlying_model::UnderlyingModel
  children::Vector{Sample{S,T}}
  parent::Union{Nothing, Sample{S,T}}
  lowered_sample::LoweredSample{<:S,T}
  first_stopped::StoppingOpportunity{T}
end



"""
sample_helper is recursive.
- Locates its current timestamp (the parent`s time) in the lowered_schedule's timeline.
- Finds the target index, which is the index corresponding to the next-stopping_opportunity's last timestamp.
It chains the first sampled lowered_sample to the parent, then it recursively chain the lowered_sample until the current index is equal to the target index.
It then fetch the required timestamps, and evaluate the condition. 
Depending on the answer, it either 
  True :  creates a sample object, and branches into the children, then finish initialization of sample object
  False : continue the loop.
"""

function sample_helper(parent_lowered_sample::Union{Nothing, LoweredSample{S,T}}, parent_sample, lowered_schedule::LoweredSchedule{T}, underlying_model::UnderlyingModel) where {S <: State, T}

  current_lowered_sample = parent_lowered_sample

  current_stopping_opportunity_index = get_current_stopping_opportunity_index(current_lowered_sample.time, lowered_schedule)


  # For each timestamp where we have to make a decision
  for stopping_opportunity in lowered_schedule.stopping_time.stopping_opportunity_list[current_stopping_opportunity_index:end]

    # Sample and chain lowered samples up to the target
    current_lowered_sample = forward(current_lowered_sample, stopping_opportunity, lowered_schedule, underlying_model)
    

    # After forwarding we have the condition that current_lowered_sample contains all the information needed to answer the stopping opportunity's predicate
    
    state_list = find(stopping_opportunity.timestamp_list, current_lowered_sample, parent_sample, lowered_schedule)

    if stopping_opportunity.predicate(state_list)

     # The condition is met, hence we generate a new sample object
      sample = Sample(current_lowered_sample.state, current_lowered_sample.time, lowered_schedule.stopping_time, underlying_model, Sample{State,T}[], parent_sample, current_lowered_sample, stopping_opportunity) 
     
      if isempty(lowered_schedule.children) # Leaf
        return sample
      end
      # Recursively get the children
      sample.children = [sample_helper(current_lowered_sample, sample, child_schedule, underlying_model) for child_schedule in lowered_schedule.children]
      return sample
    end
  end
  return nothing # if no predicate was satisfied, then w
end


"""
    Sample
"""
function Sample(state::State, schedule::Schedule{T}, underlying_model::UnderlyingModel) where {T}

  lowered_schedule = lower(schedule)
  
  lowered_sample = LoweredSample(state, lowered_schedule.timeline[1], nothing) # Nothing for parent.

  return sample_helper(lowered_sample, nothing, lowered_schedule, underlying_model) # parent is set to nothing
end

end