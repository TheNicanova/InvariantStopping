"""
    PricingModel

An abstract type representing pricing algorithms. To define a new pricing algorithm, one must do (2) things. 
  - Declare the node cache : must provide a constructor for a SampleCache object that will be used to store computations across children.
  - Declare the node logic : what computation to do at each node.
"""
abstract type PricingModel end



"""
    LayerPricingModel

  An abstract type representing pricing algorithm that also operate on layers as well. To define a new pricing algorithm, one must do an *additional* (2) things. 
    - Declare the layer cache : must provide a constructor for a LayerCache object that will be used to store computations across layers.
    - Declare the layer logic : what computation the algorithm at each layer.
  """
abstract type LayerPricingModel{T <: Layer{<: Sample,<: PricingModel}} <: PricingModel end

struct Basic <: PricingModel end

get_sample_cache(::Basic) = BasicSampleCache(0.0, 0.0)

function update!(n::WrappedNodeSample) 
  
end