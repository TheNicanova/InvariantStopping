
module Policy

export StoppingTime
export DeterministicTime
export HittingTime
export timestamp
export StoppingOpportunity
export HittingTime


"""
    StoppingOpportunity
"""
struct StoppingOpportunity{T <: Number}
    predicate::Function
    timestamp_list::Vector{T}
end

"""
    StoppingTime
"""
struct StoppingTime{T<: Number}
    stopping_opportunity_list::Vector{StoppingOpportunity{T}} # Perphaps there is a <: missing
end


####### Methods ######


"""
    DeterministicTime
"""
function DeterministicTime(time)
    always_true = (t,_) -> true
    stopping_opportunity = StoppingOpportunity(always_true, [time])
    return StoppingTime([stopping_opportunity])
end


# Stopping opportunity Methods

function timestamp(stopping_opportunity::StoppingOpportunity)
    return stopping_opportunity.timestamp_list
end

# Stopping Time methods
function timestamp(stopping_time::StoppingTime)
    list_of_list_of_timestamp = [timestamp(stopping_opportunity) for stopping_opportunity in stopping_time.stopping_opportunity_list]
    return sort!(union(list_of_list_of_timestamp...)) # the union will remove the duplicates if any
end



##########################


"""
    HittingTime
"""
function HittingTime(predicate, time_list)
    return StoppingTime([StoppingOpportunity(predicate, [timestamp]) for timestamp in time_list])
end


end