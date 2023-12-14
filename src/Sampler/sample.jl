   """
    Sample

Abstract type representing a realization. 
"""
abstract type Sample{S <: State, T <: LoweredSchedule} end


"""
    RootSample <: Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref) and a collection of [`Sample`](@ref). 
Each of the later is to be interpreted as happening at a later point in time.
"""
 struct RootSample{S,T <: LoweredRootSchedule} <: Sample{S,T}
  state::S
  schedule::T
  underlying_model::UnderlyingModel
  children::Vector{<:Sample}
end

"""
    NodeSample <: Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref) and a collection of [`Sample`](@ref). 
Each of the later is to be interpreted as happening at a later point in time.
"""
struct NodeSample{S,T <: LoweredNodeSchedule, N} <: Sample{S,T}
  state::S
  schedule::T
  underlying_model::UnderlyingModel
  children::Vector{<:Sample}
  immediate_parent
  parent::Sample
end


"""
    LeafSample <: Sample

This type stores a [`State`](@ref), a [`Schedule`](@ref), an [`UnderlyingModel`](@ref).
To be interpreted as the last piece of sample data along a schedule branch.
"""
struct LeafSample{S,T <: LoweredLeafSchedule} <: Sample{S,T}
  state::S
  schedule::T
  underlying_model::UnderlyingModel
  immediate_parent
  parent::Sample
  
end


struct TimeStampSample{S}
  state::S
end

function sample_helper(schedule::LoweredLeafSchedule, parent)
  index = findfirst

function sample(schedule::LoweredRootSchedule)
   
end

