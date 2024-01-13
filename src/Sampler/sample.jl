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
end


"""
    LoweredSample

This type stores the basic unit of sampling events.
"""
struct LoweredSample{S <: State}
  state::S
  parent::Union{Nothing, LoweredSample{S}}
end


# Sample move from 
function sample(initial_state::State, schedule::Schedule, underlying_model::UnderlyingModel)

  if initial_state.time > schedule.stopping_time[1].timelist[1]
    error("Initial state after some timestamps.")
  end

  this_sample = LoweredSample(initial_state, nothing)
  lowered_schedule = lower(schedule)

  sample_helper(this_sample, lowered_schedule, underlying_model)

end


function sample_helper(parent::Sample, lowered_schedule::LoweredSchedule, underlying_model)


current_time = parent.state.time

  for stopping_opportunity in lowered_schedule.stopping_time.stopping_opportunity_list

    if stopping_opportunity.time_list[end] < current_time # Iterate until we find the next stopping opportunity
      continue
    end

    # link lowered samples all the way to the last time stamp of stopping time
    lowered_sample, stopping_opportunity = forward(parent, lowered_schedule, underlying_model)
    find(stopping_opportunity.time_list, sample)
    # TODO, fix this above

    # Branching out
    if stopping_opportunity.predicate(state_list)
      sample = Sample(lowered_sample.state, lowered_schedule.stopping_time, underlying_model, [], parent, lowered_sample)
      if isempty(lower_schedule.children)
        return sample
      else
        sample.children = [sample_helper(sample, i, underlying_model) for i in lowered_schedule.children]
        return sample
    end

  end

  return nothing # no predicate was satisfied
end

