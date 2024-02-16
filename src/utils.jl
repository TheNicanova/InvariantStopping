module Utils
  
export get_history
export get_lower_history
export get_trajectory
export get_lower_trajectory
export get_leaf
export get_lower_leaf


using ..Sampler

#function price(sample::Sample, pricing_model::PricingModel, option::Option) end

# Returns the trajectory from root to sample at the highest level.
"""
    get_history
"""
function get_history(sample::S) where {S}
  sample_list = S[sample]

  current_sample = sample
  while !isnothing(current_sample.parent)
    push!(sample_list, current_sample.parent)
    current_sample = current_sample.parent
  end
  return reverse!(sample_list)
end


# Returns the trajectory from root to sample at the lowest level.
function get_lower_history(sample::T) where {T} 
  return get_history(sample.lowered_sample)
end


"""
    get_leaf
"""
function get_leaf(sample)
  if isempty(sample.children) || isnothing(sample.children)
    return [sample]
  else
    return union([get_leaf(child) for child in sample.children]...)
  end
end

function get_lower_leaf(sample)
  leaf_list = get_leaf(sample)
  return [leaf.lowered_sample for leaf in leaf_list]
end


function get_lower_trajectory(sample)
  trajectory_list = []
  list = get_leaf(sample)
  for leaf in list
    push!(trajectory_list, get_lower_history(leaf))
  end
  return trajectory_list
end


"""
    get_trajectory
"""
function get_trajectory(sample)
  trajectory_list = []
  list = get_leaf(sample)
  for leaf in list
    push!(trajectory_list, get_history(leaf))
  end
  return trajectory_list
end

end