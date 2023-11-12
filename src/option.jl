abstract type Option end

struct Put <: Option 
  strike_price::Number
end

function reward(state::State{1,<:Number, <:Number }, option::Put)
  return max(0, option.strike_price - get_coord(state)[1] )
end


struct Call <: Option 
  strike_price::Number
end


function reward(state::State{1,<:Number, <:Number }, option::Call)
  return max(0,  get_coord(state)[1] - option.strike_price)
end