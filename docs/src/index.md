# InvariantStopping

*A parametrized Monte Carlo solver for the optimal stopping problem.*

A package for simulating trajectories, running optimal stopping algorithms, plotting results, as well as exploring how optimal stopping problems transform under random-time coordinate transforms.


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

### Sampling

In order to generate samples, we must first specify an initial state, a schedule and an underlying model.

```julia
julia> initial_state = State(0.0,1.0) # (time,coord)

julia> schedule = Schedule(LinRange(0.0, 10, 20)) 

julia> underlying_model = GeometricBrownianMotion(3,4,5); #rate, sigma, dividend
```

The underlying_model, starting from the initialgit 

### Pricing

To price (or solve) the optimal stopping problem, one needs a Sample object as well as a PricingModel.

```julia
julia> pricing_model = Longstaff() # Returns a pricing model (Longstaff approach) set with default settings

julia> result = price(sample, pricing_model)
```

Again, one can plot the results. For instance, one has:
```julia
julia> plot(result)
```





