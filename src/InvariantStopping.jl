module InvariantStopping

export State

export StoppingOpportunity
export StoppingTime
export DeterministicTime
export HittingTime

export Schedule
export LoweredSchedule


export BrownianMotion
export GeometricBrownianMotion
export UnderlyingModel

export Sample
export LoweredSample

export get_sample
export get_all_timestamp
export get_all_leaf
export get_all_trajectory
export get_history



include("sample.jl")
include("utils.jl")
include("plot.jl")

end