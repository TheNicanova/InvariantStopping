abstract type WrappedSample{S <: Sample, T <: SampleCache} end

struct WrappedRootSample{S,T} <: WrappedSample{S,T}
  sample::Sample
  cache::SampleCache
  children::Vector{WrappedSample{S,T}}
end

struct WrappedNodeSample{S,T} <: WrappedSample{S,T}
  sample::Sample
  cache::SampleCache
  children::Vector{WrappedSample{S,T}}
end

struct WrappedLeafSample{S,T} <: WrappedSample{S,T}
  sample::Sample
  cache::SampleCache
end

