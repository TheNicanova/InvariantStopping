using Test

import InvariantStopping


@testset "All Tests" begin

  @testset "State" begin
    @test InvariantStopping.State(0,1) isa InvariantStopping.State
    @test InvariantStopping.State(0.0,1.0) isa InvariantStopping.State
    @test InvariantStopping.State(0.0,(1.0,3.0)) isa InvariantStopping.State
  end

  @testset "StoppingPolicy" begin
    @test InvariantStopping.DeterministicStopping(0.1) isa InvariantStopping.StoppingPolicy
  end

  @testset "Schedule" begin
    @test InvariantStopping.Schedule(LinRange(0,10,11)) isa InvariantStopping.LayeredSchedule
    @test schedule = InvariantStopping.Tree(LinRange(0,4,5),2) isa InvariantStopping.LayeredSchedule
  end

  @testset "UnderlyingModel" begin
    @test underlying_model = InvariantStopping.GeometricBrownianMotion(0.01, 0.05, 0.0) isa InvariantStopping.UnderlyingModel
  end

  @testset "Sample" begin
    state = InvariantStopping.State(0.0,1.0)
    schedule = InvariantStopping.Tree(LinRange(0,4,5),2)
    underlying_model = InvariantStopping.GeometricBrownianMotion(0.01, 0.05, 0.0)
    
    @test InvariantStopping.Sample(state, schedule, underlying_model) isa InvariantStopping.Sample 
  end

end
