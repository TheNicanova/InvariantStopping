using Test

using InvariantStopping


@testset "All Tests" begin

  @testset "State" begin
    @test State(1.0) isa State
    @test State((1.0,3.0)) isa State
  end

  @testset "StoppingTime" begin
    @test DeterministicTime(0.1) isa StoppingTime
    stopping_op1 = StoppingOpportunity((x,y)->true, [3,5])
    stopping_op2 = StoppingOpportunity(x->true, [4])
    stopping_time = StoppingTime([stopping_op1,stopping_op2])
    @test InvariantStopping.timestamp(stopping_time) == [3,4,5]
  end

  @testset "Schedule" begin
    @test Schedule(LinRange(0,10,11)) isa Schedule
    @test InvariantStopping.Tree(LinRange(0,4,5),2) isa Schedule
    @test InvariantStopping.Star(LinRange(0,4,5),2) isa Schedule
  end

  @testset "LoweredSchedule" begin
    schedule = Schedule(LinRange(0,10,11))
    @test InvariantStopping.lower(schedule) isa LoweredSchedule
  end

  @testset "UnderlyingModel" begin
    @test underlying_model = GeometricBrownianMotion(0.01, 0.05, 0.0) isa InvariantStopping.UnderlyingModel
  end

  @testset "Sample" begin
    state = State(0.0)
    schedule = InvariantStopping.Tree(LinRange(0,1,5), 2)
    underlying_model = GeometricBrownianMotion(0.01, 0.05, 0.0)
    sample = Sample(state, schedule, underlying_model)
    leaf = InvariantStopping.get_leaf(sample)[1]
    history = InvariantStopping.get_history(leaf)
    @test sample isa Sample 
    @test leaf isa Sample
  end

  @testset "BrownianMotion" begin
    state = State(0.0)
    schedule = InvariantStopping.Tree(LinRange(0,1,5), 2)
    underlying_model = BrownianMotion()
    sample = Sample(state, schedule, underlying_model)
    leaf = InvariantStopping.get_leaf(sample)[1]
    history = InvariantStopping.get_history(leaf)
    @test sample isa Sample 
    @test leaf isa Sample
  end



  @testset "Plot" begin
    state = State((0.0))
    schedule = InvariantStopping.Tree(LinRange(0,1,5), 2)
    underlying_model = BrownianMotion()
    sample = Sample(state, schedule, underlying_model)
    plot = InvariantStopping.plot(sample)
  end

  @testset "Plot2D" begin
    state = State((0.0,0.0))
    schedule = InvariantStopping.Tree(LinRange(0,1,5), 2)
    underlying_model = BrownianMotion()
    sample = Sample(state, schedule, underlying_model)
    plot = InvariantStopping.plot2D(sample)
  end

  function ZeroFive(truth_value)
    predicate = x -> truth_value
    return StoppingOpportunity(predicate, [0.0,5.0])
end

function ZeroFour(truth_value)
    predicate = x -> truth_value
    zero = StoppingOpportunity(predicate, [0.0, 4.0])
end

function OneFive(truth_value)
    predicate = x -> truth_value
    return StoppingOpportunity(predicate, [1.0,5.0])
end

function OneFour(truth_value)
    predicate = x -> truth_value
    return StoppingOpportunity(predicate, [1.0,4.0])
end

function Zero(truth_value)
  predicate = x -> truth_value
  return StoppingOpportunity(predicate, [0.0])
end

function One(truth_value)
  predicate = x -> truth_value
  return StoppingOpportunity(predicate, [1.0])
end

function Two(truth_value)
  predicate = x -> truth_value
  return StoppingOpportunity(predicate, [2.0])
end

function Three(truth_value)
  predicate = x -> truth_value
  return StoppingOpportunity(predicate, [3.0])
end

function Four(truth_value)
  predicate = x -> truth_value
  return StoppingOpportunity(predicate, [4.0])
end

  @testset "Correctness - Stopping Opportunity" begin
    state = State((0.0,0.0))
    underlying_model = BrownianMotion()

    schedule_t1 = Schedule(StoppingTime([ZeroFour(true), OneFive(true)])) # Checks that it simulates 1.schedule_t2 = Schedule(StoppingTime([one_five, zero_five])) # Check that it simulates 0
    @test lower(schedule_t1).timeline == [0.0,1.0,4.0,5.0]
    schedule_t2 = Schedule(StoppingTime([OneFive(true), ZeroFive(true)])) # Check that it simulates 0
    @test lower(schedule_t2).timeline == [0.0,1.0,5.0]
  end

  @testset "Correctness - Stopping Time" begin
    state = State((0.0,0.0))
    underlying_model = BrownianMotion()

    schedule_1_1 = Schedule(StoppingTime([One(true),Three(true)]),[])
    schedule_1_2 = Schedule(StoppingTime([Two(true),Four(true)]),[])
    schedule_1 = Schedule(StoppingTime([Zero(true),One(true)]), [schedule_1_1, schedule_1_2])
    lowered_schedule = lower(schedule_1)
    @test lowered_schedule.children[1].timeline == [0.0,1.0,3.0]
    @test lowered_schedule.children[2].timeline == [0.0,1.0,2.0,4.0]
    @test lowered_schedule.timeline == [0.0,1.0]
  end

  @testset "Correctness - Sampler" begin
    state = State((0.0,0.0))
    underlying_model = BrownianMotion()

    schedule_1_1 = Schedule(StoppingTime([One(true),Three(true)]),[])
    schedule_1_2 = Schedule(StoppingTime([Two(false),Four(true)]),[])
    schedule_1 = Schedule(StoppingTime([Zero(false),One(true)]), [schedule_1_1, schedule_1_2])
    sample = Sample(state, schedule_1, underlying_model)

    history_1_1 = InvariantStopping.get_history(sample.children[1])
    history_1_2 = InvariantStopping.get_history(sample.children[2])
    @test history_1_1[1].time == 1.0
    @test history_1_1[2].time == 1.0
    @test history_1_2[1].time == 1.0
    @test history_1_2[2].time == 4.0
  end
end 
