module InvariantStopping


# Fix the Union{Nothing, ...} so we can write the constructor sample(initial, underlying_model, schedule)::Sample
# initial time needs to agree with schedule time. Perhaps have a rootsample, rootschedule.

export State


export StoppingOpportunity
export StoppingTime
export DeterministicTime
export timestamp
export HittingTime


export Schedule
export lower
export LoweredSchedule


export BrownianMotion
export GeometricBrownianMotion
export ModuloTwo

export Sample
export LoweredSample

export plot
export plot2D
export lower_plot2D

include("Sampler/simulation_state.jl")
include("Sampler/policy.jl")
include("Sampler/scheduler.jl")
include("Sampler/transition.jl")
include("Sampler/sampler.jl")
include("utils.jl")
include("plot.jl")

using .SimulationState
using .Policy
using .Scheduler
using .Sampler
using .Transition
using .Utils
using .Plot

end