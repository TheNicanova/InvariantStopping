import Gadfly

"""
    plot(::Sample)

Plot a sample with the x-axis representing time and the y-axis representing the first coordinate.

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
function plot(sample::Sample)
  p = Gadfly.plot()
  push!(p, Gadfly.Guide.title("A sample"))
  push!(p, Gadfly.Guide.xlabel("Time"), Gadfly.Guide.ylabel("Coord"))
  plot(p, sample)
  return p
end


function plot(layered_sample::LayeredSample)
  plot(layered_sample.sample)
end

"""
    plot(::Any, ::NodeSample)

A helper function for recursively plotting trajectories.
"""
function plot(p::Any, sample::Union{RootSample, NodeSample})
  start_time = get_time(sample)
  start_coord = get_coord(sample)[1]
  for child in sample.children
    end_time = get_time(child)
    end_coord = get_coord(child)[1]
    push!(p, Gadfly.layer(x=[start_time,end_time], y=[start_coord, end_coord],Gadfly.Geom.line))
    plot(p, child)
  end
end

function plot(p, ::LeafSample) end
