"""
    State


Fields

    time: Represents concrete time.
julia
    coord: An N dimensional coordinate.

    A state is an object that contains the time and coordinates of a given realization.
"""
struct State{N, V <: Number}
  coord::NTuple{N, V}
end

State(coord::Number) = State((coord,))

