
module Plot

export plot
export plot2D
export lower_plot2D

import Gadfly

using ..Utils
using ..Sampler


"""
    plot(::Sample)

1D : Plot a sample with the x-axis representing time and the y-axis representing the first coordinate.

Examples:
```julia

state = State(0.0,(1.0,))
binary_tree = Schedule(LinRange(0,10,11),2)
underlying_model = GeometricBrownianMotion(0.01,0.05,0.0)

sample = Sample(state, tree, underlying_model)

plot(sample)
```
![Sample plot](assets/plot_sample.svg)

```julia

state = State(0.0,(1.0,))
star = Star(LinRange(0,10,11),12)
underlying_model = GeometricBrownianMotion(0.01,0.05,0.0)

sample = Sample(state, star, underlying_model)

plot(sample)
```
![Sample plot](assets/star.svg)


"""
function plot(sample::Union{Sample,LoweredSample})
  p = Gadfly.plot()
  push!(p, Gadfly.Guide.title("1D plot of sample's first coordinate"))
  push!(p, Gadfly.Guide.xlabel("Time"), Gadfly.Guide.ylabel("Coord"))
  plot_helper(p, sample)
  return p
end

function plot(nothing::Nothing) 
  print("Argument is nothing")
end


"""
    plot(::Any, ::NodeSample)

A helper function for recursively plotting trajectories.
"""
function plot_helper(p, sample)
  start_time = sample.time
  start_coord = sample.state.coord
  for child in sample.children
    end_time = child.time
    end_coord = child.state.coord
    push!(p, Gadfly.layer(x=[start_time,end_time], y=[start_coord[1], end_coord[1]],Gadfly.Geom.line))
    plot_helper(p, child)
  end
end

function plot2D(sample)
  p = Gadfly.plot()
  push!(p, Gadfly.Guide.title("2D plot of sample's first 2 coordinates"))
  push!(p, Gadfly.Guide.xlabel("x Coord"), Gadfly.Guide.ylabel("y Coord"))
  leafs = get_leaf(sample)
  for leaf in leafs
    trajectory = get_history(leaf)
    x_coord = [sample.state.coord[1] for sample in trajectory]
    y_coord = [sample.state.coord[2] for sample in trajectory]
    push!(p, Gadfly.layer(x=x_coord, y=y_coord),Gadfly.Geom.path)
  end
  return p
end



function lower_plot2D(sample::Sample)
  p = Gadfly.plot()
  push!(p, Gadfly.Guide.title("2D plot of lowered sample's first 2 coordinates"))
  push!(p, Gadfly.Guide.xlabel("x Coord"), Gadfly.Guide.ylabel("y Coord"))
  lower_leafs = get_leaf(sample)
  for leaf in lower_leafs
    lower_trajectory = get_lower_history(leaf)
    x_coord = [sample.state.coord[1] for sample in lower_trajectory]
    y_coord = [sample.state.coord[2] for sample in lower_trajectory]
    push!(p, Gadfly.layer(x=x_coord, y=y_coord),Gadfly.Geom.path)
  end
  return p
end

end