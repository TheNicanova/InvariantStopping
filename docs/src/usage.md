# Usage



## Installation

InvariantStopping can be installed using the Julia package manager.
From the Julia REPL, type `]` to enter the Pkg REPL mode and run

```
pkg> add InvariantStopping
```
or with `using Pkg; Pkg.add("InvariantStopping")`.

## Usage example

First, we load InvariantStopping (if we haven't already done so):
```julia
julia> using InvariantStopping
```


In order to generate samples, we must first specify an initial state, a schedule and an underlying model.

```julia
julia> initial_state = State(0.0,1.0) # (x coord, y coord)

julia> schedule = Schedule(LinRange(0.0, 10, 20)) 

julia> underlying_model = BrownianMotion(); 

julia> sample = Sample(state, schedule, underlying_model)
```

TODO: Attach image of plot(sample)


Here the schedule correponds to a simple path generated at deterministic times. We can specify more sophisticated schedule. For instance

```julia
function predicate_1(x,y) 
  return x - 2.0*y > 1.0
end

function predicate_2(x,y)
  return x + 1.0 > 0.5
end

julia> stopping_time_1 = HittingTime(predicate_1, LinRange(0.0,10,20))
julia> stopping_time_2 = HittingTime(predicate_2, LinRange(0.0,10,20))

julia> schedule = Schedule(stopping_time_1, [Schedule(stopping_time_2)for _ in 1:10])

julia> sample = Sample(state,schedule, underlying_model)
```

TODO: Attach imageo of plot(sample)


## API


```@docs
get_trajectory(::Sample)
```

```@docs
get_leaf(::Sample)
```

### Plotting 

```@docs
plot(::Sample)
```

