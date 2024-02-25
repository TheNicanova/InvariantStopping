

# TODO: Make the interface of creating predicate more flexible. E.g. being able to define predicate by (x,y) -> ..., or (t, [x,y]) -> ....

"""
    StoppingOpportunity

A Stopping Opportunity is a fundamental unit of stopping: it can only stop at one specific time.
It consists of
* A list of timestamps. The last timestamp in this list specifies when the predicate is evaluated to decide on stopping.
* A function that determines whether stopping should occur based on the current time and the states associated with each timestamp in timestamp_list.
"""
struct StoppingOpportunity{T <: Number}
    timestamp_list::Vector{T}
    predicate::Function
end

"""
    StoppingTime

A stopping time stops at the first  stopping opportunity for which its predicate returns true.

It consists simply of a list of stopping opportunities.
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
    stopping_opportunity = StoppingOpportunity([time], always_true)
    return StoppingTime([stopping_opportunity])
end


# Stopping opportunity Methods

"""
    get_all_timestamp
"""
function get_all_timestamp(stopping_opportunity::StoppingOpportunity)
    return stopping_opportunity.timestamp_list
end

function get_all_timestamp(stopping_time::StoppingTime)
    list_of_list_of_timestamp = [get_all_timestamp(stopping_opportunity) for stopping_opportunity in stopping_time.stopping_opportunity_list]
    return sort!(union(list_of_list_of_timestamp...)) # the union will remove the duplicates if any
end


##########################


"""
    HittingTime

Evalues the provided predicate at each timestamp in timestamp_list.
"""
function HittingTime(timestamp_list, predicate)
    return StoppingTime([StoppingOpportunity([timestamp],predicate) for timestamp in timestamp_list])
end
