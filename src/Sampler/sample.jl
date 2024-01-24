

##### Sampler

"""
    LoweredSample

This type stores the basic unit of sampling events.
"""
struct LoweredSample{S <: State, T <: Number}
  state::S
  time::T
  parent::Vector{LoweredSample{S,T}}
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

function check_condition(lowered_sample, lowered_schedule)
  current_stopping_opportunity = get_stopping_opportunity(current_lowered_sample, lowered_schedule)
  state_list = find(current_stopping_opportunity.timestamp_list, current_lowered_sample)
  return current_stopping_opportunity.predicate(state_list)
end


function forward(lowered_sample::LoweredSample{S,T}, target_timestamp, lowered_schedule::LoweredSchedule{T}, underlying_model::UnderlyingModel) where {S,T}
  
  current_lowered_sample = lowered_sample
  
  sampling_timestamp_list = get_sampling_timestamp_list(current_lowered_sample.time, target_timestamp, lowered_schedule)

  for sampling_timestamp in sampling_timestamp_list
      new_state = forward(current_lowered_sample.state, current_lowered_sample.time, sampling_timestamp, underlying_model)
      new_lowered_sample = LoweredSample(new_state, current_lowered_sample)
      current_lowered_sample = new_lowered_sample
  end
  return lowered_sample
end

"""
    Sample <: Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref) and a collection of [`Sample`](@ref). 
Each of the later is to be interpreted as happening at a later point in time.
"""
mutable struct Sample{S <: State, T <: Number}
  state::S
  time::T
  stopping_time::StoppingTime{T}
  underlying_model::UnderlyingModel
  children::Vector{<:Sample}
  parent::Vector{<:Sample}
  lowered_sample::LoweredSample{S}
  stopping_time_index_of_first_stopped::Int
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

function sample_helper(parent::Sample, lowered_schedule::LoweredSchedule{T}, underlying_model::UnderlyingModel) where {T}

  current_lowered_sample = parent.lowered_sample
  
  decision_timestamp_list = get_decision_timestamp_list(current_lowered_sample, lowered_schedule)

  # For each timestamp where we have to make a decision
  for decision_timestamp in decision_timestamp_list

    # Sample and chain lowered samples up to the target
    current_lowered_sample = forward(current_lowered_sample, decision_timestamp, lowered_schedule, underlying_model)
    
    # After forwarding we have the condition that current_lowered_sample.timestamp == decision_timestamp.
    if check_condition(current_lowered_sample, lowered_schedule)
     # The condition is met, we generate a new sample object
      sample = Sample(current_lowered_sample.state, current_lowered_sample.time, lowered_schedule.stopping_time, underlying_model, Sample{State,T}[], parent, current_lowered_sample, current_stopping_opportunity_index) 
     
      if isempty(lowered_schedule.children) # Leaf
        return sample
      end
      # Recursively get the children
      current_sample.children = [sample_helper(sample, child_schedule, underlying_model) for child_schedule in lowered_schedule.children]
      return sample
    end
  end

  return nothing # if no predicate was satisfied, then we return nothing.
end


function sample(state::State, schedule::Schedule{T}, underlying_model::UnderlyingModel) where {T}

  lowered_schedule = lower(schedule)
  
  current_lowered_sample = LoweredSample(state, lowered_schedule.timeline[1], LoweredSample{State,T}[]) # Empty set for parent.

  decision_timestamp_list = get_decision_timestamp_list(current_lowered_sample.time, lowered_schedule)
    # For each timestamp where we have to make a decision
    for decision_timestamp in decision_timestamp_list

      # Sample and chain lowered samples up to the target
      current_lowered_sample = forward(current_lowered_sample, decision_timestamp, lowered_schedule, underlying_model)
      
      # After forwarding we have the condition that current_lowered_sample.timestamp == decision_timestamp.
      if check_condition(current_lowered_sample, lowered_schedule)
       # The condition is met, we generate a new sample object
        sample = Sample(current_lowered_sample.state, current_lowered_sample.time, lowered_schedule.stopping_time, underlying_model, Sample{State,T}[], parent, current_lowered_sample, current_stopping_opportunity_index) 
       
        if isempty(lowered_schedule.children) # Leaf
          return sample
        end
        # Recursively get the children
        current_sample.children = [sample_helper(sample, child_schedule, underlying_model) for child_schedule in lowered_schedule.children]
        return sample
      end
    end
  
    return nothing # if no predicate was satisfied, then we return nothing.
  end
