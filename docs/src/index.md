# Usage

Explore how optimal stopping problems transform under random-time coordinate transforms.

## Installation



InvariantStopping can be installed by running
```julia
using Pkg; 
Pkg.add("InvariantStopping")
```


You can validate the success of the installation by running the following toy example.


```@example 1
using InvariantStopping

using Gadfly # hide
set_default_plot_size(6inch, 4inch) # hide
state = State(0.0) # x coord
schedule = InvariantStopping.Tree(LinRange(0,10,4), 4)
process = BrownianMotion()
sample = get_sample(state, schedule, process)
nothing # hide
```

The generated [`Sample`](@ref) is a tree of trajectories made by a standard 1 dimensional [`BrownianMotion`](@ref) initialized at given [`State`](@ref).

```@example 1
p = InvariantStopping.plot(sample) # Plot 1D
draw(SVG("ternary_tree_1D.svg"), p); # hide
nothing # hide
```

![](ternary_tree_1D.svg)


## Overview

This package's main purpose is to sample a process according to a directed tree over the space of stopping times.

Perhaps the best way to understand the idea is with an example. Let's set 

```@example 1
state = State(0.0) 
process = BrownianMotion()
nothing # hide
```
as before, but instead of having a tree over [`DeterministicTime`](@ref) let us define a tree over more generic [`StoppingTime`](@ref).

### Stopping Times

To build our stopping , we first need a few predicates.

```@example 1
function small_deviation(t,state_list)
  x = state_list[1].coord[1]  
  return (x > 0.3) || t >= 10.0
end

function medium_deviation(t,state_list)
  x = state_list[1].coord[1]
  return (x < -0.3) || t >= 10.0
end

function large_deviation(t,state_list)
  x = state_list[1].coord[1]
  return (abs(x) > 0.4) || t >= 10.0
end
```
Then, we create  [`HittingTime`](@ref) constructor, we create three stopping times.

```@example 1
timelist = LinRange(0,10,100)

small_deviation_hit= HittingTime(timelist, small_deviation)
medium_deviation_hit = HittingTime(timelist, medium_deviation)
large_deviation_hit = HittingTime(timelist, large_deviation)
nothing #hide
```

A hitting

### Schedule

We induce an ordering on our stopping times via a directed graph made of [`Schedule`](@ref) nodes.

```@example 1
deviation_escalation = Schedule(small_deviation_hit, [Schedule(medium_deviation_hit, [Schedule(large_deviation_hit) for _ in 1:10 ]) for _ in 1:10])

schedule = Schedule(DeterministicTime(0.0), [deviation_escalation for _ in 1:10])
nothing #hide
```
The above schedule defines a tree where each layer is populated by a single type of stopping time. Let's see what our original 1-dimensional Brownian motion looks like when sampled according to our newly defined schedule.

```@example 1
sample = get_sample(state, schedule, process)
p = InvariantStopping.plot(sample) # Plot 1D
draw(SVG("deviation_explosion.svg"), p); # hide
nothing # hide
```

![](deviation_explosion.svg)

What can observe that some paths were stopped before reaching the end.

Note that this shows only the actual [`Sample`](@ref), as opposed to all the intermediate [`LoweredSample`](@ref) that were sampled in order to service the stopping times. If we want to include all the intermediate steps in our plot, we can do.

```@example 1
p = InvariantStopping.plot_lower(sample) # Plot 1D
draw(SVG("lowered_deviation_explosion.svg"), p); # hide
nothing # hide
```

![](lowered_deviation_explosion.svg)

### State

We could have chosen to simulate our Brownian motion in 4 Dimension as opposed to 2. 
```@example 1
state4D = State((0.0,0.0,0.0,0.0))
sample4D = get_sample(state4D, schedule, process)
nothing # hide
```

We plot our 4-dimensional process along its first two coordinates.

```@example 1
p = InvariantStopping.plot(sample4D,[1,2]) 
draw(SVG("brownian_motion_4d.svg"), p); # hide
nothing # hide
```


![](brownian_motion_4d.svg)

And 

```@example 1
p = InvariantStopping.plot_lower(sample4D,[1,2]) 
draw(SVG("lowered_brownian_motion_4d.svg"), p); # hide
nothing # hide
```


![](lowered_brownian_motion_4d.svg)


### Process

We can also change the process, for instance [`GeometricBrownianMotion`](@ref). All one has to do to create their own process is to implement the [`forward`](@ref) method.

