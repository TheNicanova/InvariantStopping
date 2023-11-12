abstract type Cache end

abstract type  SampleCache<: Cache end

abstract type  LayerCache<: Cache end

struct BasicSampleCache <: SampleCache
  reward::Number
  value::Number
end


