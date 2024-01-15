
struct StoppingOpportunity{T <: Number}
    predicate::Function
    timestamp_list::Vector{T}
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

function timestamp(stopping_opportunity::StoppingOpportunity)
    return stopping_opportunity.timestamp_list
end

# Stopping Time methods
function timestamp(stopping_time::StoppingTime)
    list_of_list_of_timestamp = [timestamp(stopping_opportunity) for stopping_opportunity in stopping_time.stopping_opportunity_list]
    return !sort(union(list_of_list_of_timestamp...)) # the union will remove the duplicates if any
end
  