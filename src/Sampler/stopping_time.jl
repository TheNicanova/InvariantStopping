
struct StoppingOpportunity{T <: Number}
    predicate::Function
    time_list::Vector{T}
end


struct StoppingTime{T<: Number}
    stopping_opportunity_list::Vector{StoppingOpportunity{T}} # Perphaps there is a <: missing
end



####### Methods ######


# Constructor
function DeterministicTime(t)
    always_true_condition = x -> true
    stopping_opportunity = StoppingOpportunity(always_true_condition, t)
    return StoppingTime([stopping_opportunity])
end


# Stopping opportunity Methods

function get_time_list(stopping_opportunity::StoppingOpportunity)
    return stopping_opportunity.time_list
end

function get_earliest_stopping_opportunity(stopping_opportunity::StoppingOpportunity)
    return stopping_opportunity.time_list[end]
end
  
# Stopping Time methods
function get_time_list(stopping_time::StoppingTime)
    list_of_list = [get_time_list(stopping_opportunity) for stopping_opportunity in stopping_time.stopping_opportunity_list]
    list = union(list_of_list...) # the union will remove the duplicates if any
    return !sort(list)
end
  
function get_earliest_stopping_opportunity(stopping_time::StoppingTime)
    return get_earliest_stopping_opportunity(stopping_time.stopping_opportunity_list[1])
end
  
function next(time, stopping_time::StoppingTime) # This can be improved for performance, even memoized.
    opportunity_time_list = [ stopping_opportunity.time_list[end] for stopping_opportunity in stopping_time.stopping_opportunity_list]
    return findfirst(x -> x >= time, opportunity_time_list)
end
