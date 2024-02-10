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
end
