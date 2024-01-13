"""
    State


Fields

    time: Represents concrete time.
julia
    coord: An N dimensional coordinate.

    A state is an object that contains the time and coordinates of a given realization.
"""
struct State{N, T <: Number, V <: Number}
  time::T
  coord::NTuple{N, V}
end


State(time::Number, coord::Number) = State(time,(coord,))

get_time(state::State) = state.time
  
get_coord(state::State) = state.coord

