include("stopping_time.jl")


"""
Meant to be as easy as possible for the user to define.
"""
struct Schedule{T <: StoppingTime}
  stopping_time::T
  children
end


# constructors

Schedule(stopping_time::T) where {T <: StoppingTime} = Schedule(stopping_time, [])


function Tree(lin::LinRange{<:Number, <:Integer}, branching_factor::Integer)

  stopping_policy = DeterministicStopping(lin[1])

  if length(lin) == 1
    children = []
  else
    children = [Tree(lin[2:end], branching_factor) for _ in 1:branching_factor]
  end

  return Schedule(stopping_policy, children)
end

Schedule(lin::LinRange{<:Number, <:Integer}) = Tree(lin,1)

function Star(lin::LinRange{<:Number,<:Integer}, branching_factor::Integer)

  stopping_policy = DeterministicStopping(lin[1])
  children = [Schedule(lin[2:end]) for _ in 1:branching_factor]

  return Schedule(stopping_policy, children)
end


