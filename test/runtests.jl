using TestItems
using TestItemRunner
@run_package_tests


@testitem "sentinelview" begin
    A = [10, 20, 30]

    Av = sentinelview(A, [1, 3], nothing)
    @test Av == [10, 30]
    @test Av isa SubArray{Int}

    Av = sentinelview(A, Union{Int, Nothing}[1, 3], nothing)
    @test Av == [10, 30]
    @test Av isa AbstractArray{Union{Int, Nothing}}

    Av = sentinelview(A, [1, nothing, 3], nothing)
    @test Av == [10, nothing, 30]
    @test Av isa AbstractArray{Union{Int, Nothing}}

    @test_throws "incompatible" sentinelview(A, [1, missing, 3], nothing)
    @test_throws "incompatible" sentinelview(A, [1, 3], 0)
end

@testitem "_" begin
    import Aqua
    Aqua.test_all(SentinelViews; ambiguities=false)
    Aqua.test_ambiguities(SentinelViews)

    import CompatHelperLocal as CHL
    CHL.@check()
end
