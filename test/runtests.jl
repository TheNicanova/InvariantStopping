using Test

using InvariantStopping

@testset "All Tests" begin

  @testset "State" begin
    @test State(1.0) isa State
    @test State((1.0,3.0)) isa State
  end


  @testset "StoppingOpportunity" begin
    @test StoppingOpportunity( [3,5], (t,x)->true) isa StoppingOpportunity
  end


  @testset "DeterministicTime" begin
    @test DeterministicTime(0.1) isa StoppingTime
  end

  @testset "HittingTime" begin
    @test HittingTime([1.0,2.0,3.0], (t,x) -> 2*t > x) isa StoppingTime
  end

  @testset "Correctness - get_all_timestamp" begin
    stopping_op1 = StoppingOpportunity([3,5],(t,x)->true)
    stopping_op2 = StoppingOpportunity([4],(t,x)->true)
    stopping_time = StoppingTime([stopping_op1,stopping_op2])
    @test InvariantStopping.get_all_timestamp(stopping_time) == [3,4,5]
  end
  
  @testset "Schedule Constructors" begin
    @test Schedule(LinRange(0,10,11)) isa Schedule
    @test InvariantStopping.Tree(LinRange(0,4,5),2) isa Schedule
    @test InvariantStopping.Star(LinRange(0,4,5),4) isa Schedule
  end


  @testset "LoweredSchedule" begin
    schedule = Schedule(LinRange(0,10,11))
    @test InvariantStopping.lower(schedule) isa LoweredSchedule
  end


#### Sampler

@testset "Geometric Brownian Motion" begin
  @test BrownianMotion() isa InvariantStopping.UnderlyingModel
end

@testset "Geometric Brownian Motion" begin
  @test GeometricBrownianMotion(0.01, 0.05, 0.0) isa InvariantStopping.UnderlyingModel
end

@testset "get_sample" begin
  state = State(0.0)
  schedule = InvariantStopping.Tree(LinRange(0,1,5), 2)
  underlying_model = GeometricBrownianMotion(0.01, 0.05, 0.0)
  sample = get_sample(state, schedule, underlying_model)
  @test sample isa Sample
end

@testset "utils" begin
  state = State(0.0)
  schedule = InvariantStopping.Tree(LinRange(0,1,5), 2)
  underlying_model = BrownianMotion()
  sample = get_sample(state, schedule, underlying_model)
  leaf = InvariantStopping.get_all_leaf(sample)[1]
  history = InvariantStopping.get_history(leaf)
  @test sample isa Sample 
  @test leaf isa Sample
end


  @testset "Plot" begin
    state = State((0.0))
    schedule = InvariantStopping.Tree(LinRange(0,1,5), 2)
    underlying_model = BrownianMotion()
    sample = get_sample(state, schedule, underlying_model)
    plot = InvariantStopping.plot(sample)
  end

  @testset "Plot2D" begin
    state = State((0.0,0.0))
    schedule = InvariantStopping.Tree(LinRange(0,1,5), 2)
    underlying_model = BrownianMotion()
    sample = get_sample(state, schedule, underlying_model)
    plot = InvariantStopping.plot(sample,[1,2])
  end

# Correctness

function op(timestamp_list, truth_value)
  return StoppingOpportunity(timestamp_list, (t,_) -> truth_value)
end

@testset "Correctness - Stopping Opportunity" begin
  state = State((0.0,0.0))
  underlying_model = BrownianMotion()

  schedule_t1 = Schedule(StoppingTime([op([0.0,4.0],true), op([1.0,5.0],true)])) # Checks that it simulates 1.schedule_t2 = Schedule(StoppingTime([one_five, zero_five])) # Check that it simulates 0
  @test InvariantStopping.lower(schedule_t1).timeline == [0.0,1.0,4.0,5.0]
  schedule_t2 = Schedule(StoppingTime([op([1.0,5.0],true), op([0.0,5.0],true)])) # Check that it simulates 0
  @test InvariantStopping.lower(schedule_t2).timeline == [0.0,1.0,5.0]
end

@testset "Correctness - Stopping Time" begin
  state = State((0.0,0.0))
  underlying_model = BrownianMotion()

  schedule_1_1 = Schedule(StoppingTime([op([1.0],true),op([3.0],true)]),[])
  schedule_1_2 = Schedule(StoppingTime([op([2.0], true),op([4.0],true)]),[])
  schedule_1 = Schedule(StoppingTime([op([0.0], true), op([1.0],true)]), [schedule_1_1, schedule_1_2])
  lowered_schedule = InvariantStopping.lower(schedule_1)
  @test lowered_schedule.children[1].timeline == [0.0,1.0,3.0]
  @test lowered_schedule.children[2].timeline == [0.0,1.0,2.0,4.0]
  @test lowered_schedule.timeline == [0.0,1.0]
end

@testset "Correctness - Sampler" begin
  state = State((0.0,0.0))
  underlying_model = BrownianMotion()

  schedule_1_1 = Schedule(StoppingTime([op([1.0],true),op([3.0],true)]),[])
  schedule_1_2 = Schedule(StoppingTime([op([2.0],false),op([4.0],true)]),[])
  schedule_1 = Schedule(StoppingTime([op([0.0],false),op([1.0],true)]), [schedule_1_1, schedule_1_2])
  sample = get_sample(state, schedule_1, underlying_model)

  history_1_1 = InvariantStopping.get_history(sample.children[1])
  history_1_2 = InvariantStopping.get_history(sample.children[2])
  @test history_1_1[1].time == 1.0
  @test history_1_1[2].time == 1.0
  @test history_1_2[1].time == 1.0
  @test history_1_2[2].time == 4.0
end

end