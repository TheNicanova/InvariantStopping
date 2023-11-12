

# Underlying Model


## State Space
```@docs
State
```

## Stopping Times

```@docs
StoppingPolicy
```

```@docs
DeterministicStopping
```

```@docs
StoppingTime
```

## Ordering Stopping Times

```@docs
Schedule
```

```@docs
RootSchedule
```

```@docs
NodeSchedule
```

```@docs
LeafSchedule
```

## Forwarding States

```@docs
UnderlyingModel
```

```@docs
GeometricBrownianMotion
```

## Sampling

```@docs
Sample
```
```@docs
RootSample
```

```@docs
NodeSample
```

```@docs
LeafSample
```

# Pricing Model

## Cache

The Cache type specifies the data that is stored and used by a given PricingModel object. Each pricing algorithm must return the Cache objects it uses.
```@docs
Cache
```

The SampleCache type specifies the format of the data that the PricingModel will store at each Sample object.
```@docs
SampleCache
```


The SampleCache type specifies the format of the data that the PricingModel will store at each Layer object.
```@docs
LayerCache
```

## PricingModel

```@docs
PricingModel
```

```@docs
LayeredPricingModel
```

### Basic

```@docs
Basic
```

```@docs
update(::Sample, ::Basic)
```

```@docs
get_cache(::Sample, ::Basic)
```



### LongStaff

### SampleCache



### LayerCache

## WrappedSampled

## Layer

## Data


