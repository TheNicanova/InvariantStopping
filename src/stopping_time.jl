"""
    StoppingTime

Abstract type that specifies when to stop.

It is either [`DeterministicStopping`](@ref) or [`StoppingTime`](@ref).
"""
abstract type StoppingTime end

"""
    DeterministicStopping <: StoppingTime

This type represents stopping at a specific concrete time as opposed to following a generic stopping time.

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
    AtomicStopping <: StoppingTime

This type represents stopping at a specific concrete time *if* a given condition on the sampled [`State`](@ref) is met.

Examples
```jldoctest
julia> atomic_stopping = AtomicStopping(1.0, x -> get_coord(x)[1] > 2.0);

julia> atomic_stopping.condition(State(1.0, (1.0,)))
false

julia> atomic_stopping.condition(State(1.0, (4.0,)))
true
```
"""
struct AtomicStopping{T <: Number, F <: Function} <: StoppingTime
    time::T
    condition::F
end