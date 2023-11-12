abstract type Layer{S <: Sample, T <: LayerCache} end

struct RootLayer{S,T} <: Layer{S,T}
  sample_list::Vector{S}
  cache::T
  next::Layer{S,T}
end

struct NodeLayer{S,T} <: Layer{S,T}
  sample_list::Vector{S}
  cache::T
  next::Layer{S,T}
end

struct LeafLayer{S,T} <: Layer{S,T}
  sample_list::Vector{S}
  cache::T
end

