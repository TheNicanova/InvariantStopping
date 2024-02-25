using Gadfly

"""
    plot(::Union{Sample,LoweredSample})

1D : Plot a sample with the x-axis representing time and the y-axis representing the first coordinate.
"""
function plot(sample::Union{Sample,LoweredSample})
  p = Gadfly.plot()
  push!(p, Gadfly.Guide.title("plot of first coordinate against time"))
  push!(p, Gadfly.Guide.xlabel("Time"), Gadfly.Guide.ylabel("Coord"))
  plot_helper(p, sample)
  return p
end

function plot(nothing::Nothing) 
  print("Argument is nothing")
end

function plot_helper(p, sample)
  start_time = sample.time
  start_coord = sample.state.coord
  for child in sample.children
    if isnothing(child)
      continue
    end
    end_time = child.time
    end_coord = child.state.coord
    push!(p, Gadfly.layer(x=[start_time,end_time], y=[start_coord[1], end_coord[1]],Gadfly.Geom.line))
    plot_helper(p, child)
  end
end

"""
  plot_lower
"""
function plot_lower(sample)
  p = Gadfly.plot()
  push!(p, Gadfly.Guide.title("plot of first coordinate against time"))
  push!(p, Gadfly.Guide.xlabel("Time"), Gadfly.Guide.ylabel("Coord"))
  plot_helper(p, sample.lowered_sample)
  return p
end


function plot(sample,index_list)
  p = Gadfly.plot()
  push!(p, Gadfly.Guide.title("2D plot of selected coordinates"))
  push!(p, Gadfly.Guide.xlabel("x Coord"), Gadfly.Guide.ylabel("y Coord"))
  leafs = get_all_leaf(sample)
  for leaf in leafs
    trajectory = get_history(leaf)
    x_coord = [sample.state.coord[index_list[1]] for sample in trajectory]
    y_coord = [sample.state.coord[index_list[2]] for sample in trajectory]
    push!(p, Gadfly.layer(x=x_coord, y=y_coord),Gadfly.Geom.path)
  end
  return p
end



function plot_lower(sample,index_list)
  p = Gadfly.plot()
  push!(p, Gadfly.Guide.title("2D plot of selected coordinates"))
  push!(p, Gadfly.Guide.xlabel("x Coord"), Gadfly.Guide.ylabel("y Coord"))
  leafs = get_all_leaf(sample)
  for leaf in leafs
    trajectory = get_lower_history(leaf)
    x_coord = [sample.state.coord[index_list[1]] for sample in trajectory]
    y_coord = [sample.state.coord[index_list[2]] for sample in trajectory]
    push!(p, Gadfly.layer(x=x_coord, y=y_coord),Gadfly.Geom.path)
  end
  return p
  
end

