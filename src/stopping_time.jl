"""
    StoppingTime

Abstract type representing a generic stopping time. Informally, a stopping time takes a sequence of [`State`](@ref) objects and returns the state object at which it stops. If it doesn't stop, the 'nothing' value should be returned. 
If the sequence of states does not contain sufficient information for the stopping time to determine when to stop, an exception should be thrown.


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

This type represents stopping times that stop at a single fixed time if and only if the provided trajectory is satisfies a list of conditions.
It takes a time parameter, a list of times at which the sampled state will be needed, a condition that takes for input a list of states and returns a boolean value.

!!! comment
It might help to consider an [`AtomicStopping`](@ref) as a *stopping opportunity*.

Examples
```jldoctest
julia> atomic_stopping = AtomicStopping(3.0, [(1.0, x -> get_coord(x[1] > 1))]);
```
"""
struct AtomicStopping{T <: Number, F <: Function} <: StoppingTime
    time::T
    time_list::Vector{T}
    condition::F
end

"""
    CompositeStopping <: StoppingTime

This type represents stopping times that can stop at any time in a list of fixed times. 
A composite stopping time is a *sorted* list of [`AtomicStopping`](@ref) and it stops at the first [`AtomicStopping`](@ref) that is satisfied.
Any generic stopping time can be represented as a composite time.  

Examples
```jldoctest
julia> atomic_stopping_1 = AtomicStopping(1.0, x -> get_coord(x)[1] > 2.0);

julia> atomic_stopping_2 = AtomicStopping(2.0, x -> get_coord(x)[1] > 2.5);

julia> composite_stopping = CompositeStopping([atomic_stopping_1, atomic_stopping_2]);

```
"""
struct CompositeStopping <: StoppingTime
    stopping_time_list::Vector{<: AtomicStopping}
end 