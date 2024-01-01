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

@testitem "view-of-view" begin
    A = [10, 20, 30, 40]
    # no nothing:
    @testset for vf in (view, sentinelview, (A,I)->SentinelViews._sentinelview(A,I,nothing))
        Av1 = vf(A, [1, 3, 4])
        Av2 = vf(Av1, [1, 3])
        @test Av2 == [10, 40]
        @test parent(Av2) === A
        @test parentindices(Av2) == ([1, 4],)
    end
    # with nothing:
    Av1 = sentinelview(A, [1, nothing, 4])
    Av2 = sentinelview(Av1, [1, 3])
    @test Av2 == [10, 40]
    @test parent(Av2) === A
    @test parentindices(Av2) == ([1, 4],)

    Av1 = sentinelview(A, [1, 3, nothing])
    Av2 = sentinelview(Av1, [1, 3])
    @test Av2 == [10, nothing]
    @test parent(Av2) === A
    @test parentindices(Av2) == ([1, nothing],)

    Av1 = sentinelview(A, [1, 3, 4])
    Av2 = sentinelview(Av1, [1, nothing])
    @test Av2 == [10, nothing]
    @test parent(Av2) === A
    @test parentindices(Av2) == ([1, nothing],)

    Av1 = sentinelview(A, [1, 3, nothing])
    Av2 = sentinelview(Av1, [1, nothing])
    @test Av2 == [10, nothing]
    @test parent(Av2) === A
    @test parentindices(Av2) == ([1, nothing],)
end

@testitem "other collections" begin
    # https://github.com/JuliaLang/julia/pull/49179
    Base.keytype(@nospecialize t::Tuple) = keytype(typeof(t))
    Base.keytype(@nospecialize T::Type{<:Tuple}) = Int

    Av = sentinelview((10, 20, 30), [1, 3], nothing)
    @test Av == [10, 30]
    @test Av isa AbstractArray{Int}

    # broken: only support eltype(I) <: keytype(A)
    # Av = sentinelview((a=10, b=20, c=30), [1, 3], nothing)
    # @test Av == [10, 30]
    # @test Av isa AbstractArray{Int}

    if VERSION ≥ v"1.10-"
        Av = sentinelview((a=10, b=20, c=30), [:a, :c], nothing)
        @test Av == [10, 30]
        @test Av isa AbstractArray{Int}
    end
end

@testitem "_" begin
    import Aqua
    Aqua.test_all(SentinelViews; ambiguities=false)
    Aqua.test_ambiguities(SentinelViews)

    import CompatHelperLocal as CHL
    CHL.@check()
end
