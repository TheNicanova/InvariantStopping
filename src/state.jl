"""
    State


Fields

    time: Represents concrete time.

    coord: An N dimensional coordinate.

!!! comment
    A state is an immutable object, perhaps it should be made mutable.

!!! comment
    We still debate as whether or not to include the time component inside the state object.


Examples
```julia
julia> state = State(0.0, (1.0,0.0))

julia> state = State(0.0, (1.0,))

julia> state = State(0.5, 1.0)

julia> time = get_time(state)

julia> coord = get_coord(state)
```
"""
struct State{N, T <: Number, V <: Number}
  time::T
  coord::NTuple{N, V}
end


State(time::Number, coord::Number) = State(time,(coord,))

get_time(state::State) = state.time
  
get_coord(state::State) = state.coord

