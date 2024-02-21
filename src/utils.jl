
"""
    get_history
  
Returns the list of samples starting from the root to the provided sample.
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

"""
    get_all_leaf

Returns a list of all leafs from the provided sample onward.
"""
function get_all_leaf(sample)
  if isempty(sample.children) || isnothing(sample.children)
    return [sample]
  else
    return union([],[get_all_leaf(child) for child in sample.children if !isnothing(child)]...)
  end
end

"""
    get_all_trajectory
  
Returns a list of all trajectories from the provided sampled onward. A trajectory is a list of states from the provided sample onward to a leaf.
"""
function get_all_trajectory(sample)
  trajectory_list = []
  list = get_all_leaf(sample)
  for leaf in list
    push!(trajectory_list, get_history(leaf))
  end
  return trajectory_list
end


# Returns the trajectory from root to sample at the lowest level.
function get_lower_history(sample::T) where {T} 
  return get_history(sample.lowered_sample)
end

function get_all_lower_trajectory(sample)
  trajectory_list = []
  list = get_all_leaf(sample)
  for leaf in list
    push!(trajectory_list, get_lower_history(leaf))
  end
  return trajectory_list
end
