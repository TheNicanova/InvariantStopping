"""
    StoppingPolicy

Abstract type that specifies when to stop.

It is either [`DeterministicStopping`](@ref) or [`StoppingTime`](@ref).
"""
abstract type StoppingPolicy end

"""
    DeterministicStopping <: StoppingPolicy

This type represents stopping at a specific concrete time as opposed to following a generic stopping time.

Examples
```julia
julia> simple_stopping_rule = DeterministicStopping(5.0)

julia> time = get_time(simple_stopping_rule) # 5.0

```
"""
struct DeterministicStopping{T <: Number} <: StoppingPolicy 
  time::T
end


"""
    StoppingTime <: StoppingPolicy

This abstract type represents a generic stopping time.
"""
abstract type StoppingTime <: StoppingPolicy end


get_time(stopping_policy::DeterministicStopping) = return stopping_policy.time