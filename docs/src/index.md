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
schedule = InvariantStopping.Tree(LinRange(0,10,4), 3)
process = BrownianMotion()
sample = get_sample(state, schedule, process)
nothing # hide
```

The generated [`Sample`](@ref) is a tree of trajectories made by a standard 1-dimensional [`BrownianMotion`](@ref) with [`State`](@ref) initialized at the origin.

```@example 1
p = InvariantStopping.plot(sample) # Plot 1D
draw(SVG("ternary_tree_1D.svg"), p); # hide
nothing # hide
```

![](ternary_tree_1D.svg)


# Overview

The target of this package is to allow the user to sample a process along arbitrary stopping times. 


Perhaps the best way to understand the idea is with an example. 

```@example 1
state = State(0.0) 
process = BrownianMotion()
nothing # hide
```
Instead of having a tree over [`DeterministicTime`](@ref) 

![Ternary Tree](assets/custom_schedule_page2.svg)

Let us define a tree over [`StoppingTime`](@ref).

![Ternary Tree](assets/custom_schedule_page3.svg)

## Stopping Times

To build our stopping times, we first need a few predicates.

```@example 1
function up_deviation(t,state_list)
  x = state_list[1].coord[1]  
  return (x > 0.3) || t >= 10.0
end

function down_deviation(t,state_list)
  x = state_list[1].coord[1]
  return (x < -0.3) || t >= 10.0
end

function large_deviation(t,state_list)
  x = state_list[1].coord[1]
  return (abs(x) > 0.4) || t >= 10.0
end
nothing # hide
```
Then we create three [hitting time](https://en.wikipedia.org/wiki/Hitting_time) using the [`HittingTime`](@ref) constructor.

```@example 1
timelist = LinRange(0,10,100)

up_deviation_hit= HittingTime(timelist, up_deviation)
down_deviation_hit = HittingTime(timelist, down_deviation)
large_deviation_hit = HittingTime(timelist, large_deviation)
nothing #hide
```

Having three stopping times, we will use them to populate our schedule.


## Schedule

We induce an ordering on our stopping times via a directed graph made of [`Schedule`](@ref) nodes.



```@example 1
deviation_escalation = Schedule(up_deviation_hit, [Schedule(down_deviation_hit, [Schedule(large_deviation_hit) for _ in 1:5 ]) for _ in 1:5])

schedule = Schedule(DeterministicTime(0.0), [deviation_escalation for _ in 1:12])
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

We can observe that some paths were stopped before reaching the end. We can also observe that our choice of schedule causes the zig-zagging trajectories to be over-represented.

Note that this shows only the actual [`Sample`](@ref), as opposed to all the intermediate [`LoweredSample`](@ref) that were sampled in order to service the stopping times. If we want to include all the intermediate steps in our plot, we can do.

```@example 1
p = InvariantStopping.plot_lower(sample) # Plot 1D
draw(SVG("lowered_deviation_explosion.svg"), p); # hide
nothing # hide
```

![](lowered_deviation_explosion.svg)

## State

We could have chosen to simulate our Brownian motion in four dimensions as opposed to two. 
```@example 1
state = State((0.0,0.0,0.0,0.0))
nothing #hide
```

Let's choose our schedule such that the process duplicates when it hits the boundary of the 4D unit sphere.

```@example 1
function sphere(t,state_list)
  return sqrt(sum([state_list[1].coord[i]^2 for i in 1:length(state_list)])) > 1 || t >= 10.0
end

function stop_at_ten(t,state_list)
  return  t >= 10.0
end

hit_ten = HittingTime(LinRange(0,10,100),stop_at_ten)
hit_sphere = HittingTime(LinRange(0,10,100), sphere)
hit_sphere_doubling = Schedule(hit_sphere, [Schedule(hit_ten) for _ in 1:2])

schedule = Schedule(DeterministicTime(0.0),[hit_sphere_doubling for _ in 1:20 ])
nothing # hide
```

We sample.
```@example 1
sample = get_sample(state,schedule,process)
nothing #hide
```
Let's plot the 4-dimensional brownian motion along its first two coordinates.

```@example 1
p = InvariantStopping.plot(sample,[1,2]) 
draw(SVG("brownian_motion_4d.svg"), p); # hide
nothing # hide
```

![](brownian_motion_4d.svg)

And 

```@example 1
p = InvariantStopping.plot_lower(sample,[1,2]) 
draw(SVG("lowered_brownian_motion_4d.svg"), p); # hide
nothing # hide
```


![](lowered_brownian_motion_4d.svg)


## Process

So far we have used the process [`BrownianMotion`](@ref) but we could a different process, for instance [`GeometricBrownianMotion`](@ref).

```@example 1
state = State(1.0)
process = GeometricBrownianMotion(0.06, 0.2, 0.0) # (rate, sigma, dividend)
nothing #hide
```

Let's see what happens if we make the process doubles once it crosses a certain threshold.

```@example 1
function space_time_deviation(t,state_list)
  x = state_list[1].coord[1]  
  return x > 4 - t/10  || t >= 10.0
end

function stop_at_ten(t,state_list)
  return  t >= 10.0
end

hit_ten = HittingTime(LinRange(0,10,100),stop_at_ten)
space_time_deviation_doubling = Schedule(HittingTime(timelist, space_time_deviation),[Schedule(hit_ten) for _ in 1:2])

schedule = Schedule(DeterministicTime(0.0),[space_time_deviation_doubling for _ in 1:15])
nothing # hide
```

```@example 1
sample = get_sample(state, schedule, process)
p = InvariantStopping.plot(sample) 
draw(SVG("geometric_brownian_motion_1d.svg"), p); # hide
nothing # hide
```

![](geometric_brownian_motion_1d.svg)

```@example 1
p = InvariantStopping.plot_lower(sample) 
draw(SVG("lower_geometric_brownian_motion_1d.svg"), p); # hide
nothing # hide
```

![](lower_geometric_brownian_motion_1d.svg)

One can define a new process by implementing the [`forward`](@ref) method for a concrete type. See  [`UnderlyingModel`](@ref).

# Summary

We have seen how the InvariantStopping package can be used to generate sample 
```julia
sample = get_sample(state, schedule, process)
```
where the state, schedule and process can be varied independently. Moreoever, the package allows one to define very generic schedule in the form of a directed tree over the space of stopping times. 

![Ternary Tree](assets/custom_schedule_page4.svg)

For more information on schedule, check [dev](dev.md).