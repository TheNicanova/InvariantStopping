"""
    State


Fields

    time: Represents concrete time.
julia
    coord: An N dimensional coordinate.

    A state is an object that contains the time and coordinates of a given realization.

Examples
```jldoctest
julia> state = State(0.0, (1.0,0.0))
State{2, Float64, Float64}(0.0, (1.0, 0.0))

julia> state = State(0.0, (1.0,))
State{1, Float64, Float64}(0.0, (1.0,))

julia> state = State(0.0, 1.0)
State{1, Float64, Float64}(0.0, (1.0,))

julia> time = get_time(state)
0.0

julia> coord = get_coord(state)
(1.0,)
```
"""
struct State{N, T <: Number, V <: Number}
  time::T
  coord::NTuple{N, V}
end


"""
    State(::Number, Number)

Helper constructor for [`State`](@ref).
"""
State(time::Number, coord::Number) = State(time,(coord,))

get_time(state::State) = state.time
  
get_coord(state::State) = state.coord

