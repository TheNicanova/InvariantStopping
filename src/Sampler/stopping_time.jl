"""
    StoppingTime

Abstract type representing a stopping time. 
There are (2) types of stopping time:

- [`DeterministicStopping`](@ref)
- [`WaitingTime`](@ref)

"""
abstract type StoppingTime end



"""
    DeterministicStopping <: StoppingTime

Represents stopping at a specific concrete time, unconditionally.

Examples
```jldoctest
julia> deterministic_stopping = DeterministicStopping(5.0)
DeterministicStopping{Float64}(5.0)

```
"""
struct DeterministicStopping{T <: Number} <: StoppingTime 
  time::T
end



"""
    StoppingOpportunity

Stopping at a time if the given condition evaluates to true. The timestamp_list indicates the timestamps required by the condition.
"""
struct StoppingOpportunity{T}
    time::T
    condition
    time_list::Vector{T}
end


"""

    WaitingTime <: StoppingTime

Represents stopping at the first [`StoppingOpportunity`](@ref) evaluating to true in the list of stopping opportunities.

"""
struct WaitingTime{T} <: StoppingTime
    stopping_opportunity_list::Vector{StoppingOpportunity{T}}
end
