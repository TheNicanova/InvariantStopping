"""
    PricingModel

An abstract type representing pricing algorithms.
"""
abstract type PricingModel end


"""
    LayerPricingModel

An abstract type representing pricing algorithms that recursively operate at the layer level. A partition of the Schedule object induces a partition of the sampled states. We call a layer an element of such partition. 
"""
abstract type LayerPricingModel <: PricingModel end


