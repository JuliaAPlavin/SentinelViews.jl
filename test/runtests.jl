using TestItems
using TestItemRunner
@run_package_tests


@testitem "basic vector" begin
    A = [10, 20, 30]

    Av = sentinelview(A, [1, 3], nothing)
    @test Av == [10, 30]
    @test Av isa SubArray{Int}
    @test_broken (sentinelview(A, [CartesianIndex(1), CartesianIndex(3)], nothing); true)  # only support eltype(I) <: keytype(A)

    Av = sentinelview(A, Union{Int, Nothing}[1, 3], nothing)
    @test Av == [10, 30]
    @test Av isa AbstractArray{Union{Int, Nothing}}

    Av = sentinelview(A, [1, nothing, 3], nothing)
    @test Av == [10, nothing, 30]
    @test Av isa AbstractArray{Union{Int, Nothing}}

    Av = sentinelview(A, [1, nothing, 3])
    @test Av == [10, nothing, 30]
    @test Av isa AbstractArray{Union{Int, Nothing}}

    @test_throws "incompatible" sentinelview(A, [1, missing, 3], nothing)
    @test_throws "incompatible" sentinelview(A, [1, 3], 0)
end

@testitem "multidim" begin
    A = [10, 20, 30]
    
    Av = sentinelview(A, [1 3; 2 1], nothing)
    @test Av == [10 30; 20 10]
    @test Av isa SubArray{Int}

    Av = sentinelview(A, [1 nothing; 2 1], nothing)
    @test Av == [10 nothing; 20 10]
    @test Av isa AbstractArray{Union{Int, Nothing}}
    @test parent(Av) === A

    A = [1 2 3; 4 5 6]

    Av = sentinelview(A, [CartesianIndex(1, 2), CartesianIndex(2, 3)], nothing)
    @test Av == [2, 6]
    @test Av isa SubArray{Int}

    Av = sentinelview(A, [CartesianIndex(1, 2);; CartesianIndex(2, 3)], nothing)
    @test Av == [2;; 6]
    @test Av isa SubArray{Int}

    Av = sentinelview(A, [CartesianIndex(1, 2), nothing, CartesianIndex(2, 3)], nothing)
    @test Av == [2, nothing, 6]
    @test Av isa AbstractArray{Union{Int, Nothing}}
    @test parent(Av) === A
end

@testitem "_" begin
    import Aqua
    Aqua.test_all(SentinelViews; ambiguities=false)
    Aqua.test_ambiguities(SentinelViews)

    import CompatHelperLocal as CHL
    CHL.@check()
end
