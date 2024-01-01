module SentinelViews

export sentinelview

struct SentinelView{T, N, A, I, TS} <: AbstractArray{T, N}
    parent::A
    indices::I
    sentinel::TS
end

function SentinelView(A, I, sentinel)
    @assert !(sentinel isa keytype(A))
    SentinelView{
        if eltype(I) <: keytype(A)
            valtype(A)
        elseif eltype(I) <: Union{keytype(A), typeof(sentinel)}
            Union{valtype(A), typeof(sentinel)}
        else
            error("incompatible: keytype(A) = $(keytype(A)), eltype(I) = $(eltype(I)), sentinel = $sentinel")
        end,
        ndims(I),
        typeof(A),
        typeof(I),
        typeof(sentinel)
    }(A, I, sentinel)
end

Base.IndexStyle(::Type{SentinelView{T, N, A, I}}) where {T, N, A, I} = IndexStyle(I)
Base.size(a::SentinelView) = size(a.indices)

Base.@propagate_inbounds function Base.getindex(a::SentinelView, is::Int...)
    I = a.indices[is...]
    I === a.sentinel ? a.sentinel : a.parent[I]
end

Base.parent(a::SentinelView) = a.parent
Base.parentindices(a::SentinelView) = (a.indices,)

"""    sentinelview(X, I, [sentinel=nothing])

Like `view(X, I)`, but propagates `sentinel`.

# Examples
```julia
A = [10, 20, 30]

Av = sentinelview(A, [1, 2, 3])  # equivalent to view(A, [1, 2, 3])
Av == [10, 20, 30]

Av = sentinelview(A, [1, nothing, 3])  # propagates nothing in indices to the result
Av == [10, nothing, 30]
```
"""
function sentinelview end

function sentinelview(A, I, sentinel=nothing)
    sentinel isa keytype(A) && error("incompatible: keytype(A) = $(keytype(A)), sentinel = $sentinel")
    _sentinelview(A, I, sentinel)
end

function sentinelview(A::AbstractArray, I::AbstractArray, sentinel=nothing)
    sentinel isa keytype(A) && error("incompatible: keytype(A) = $(keytype(A)), sentinel = $sentinel")
    if eltype(I) <: keytype(A)
        view(A, I)
    else
        _sentinelview(A, I, sentinel)
    end
end

Base.view(A::SentinelView, I) = SentinelView(parent(A), collect(sentinelview(only(parentindices(A)), I, A.sentinel)), A.sentinel)

_sentinelview(A, I, sentinel) = SentinelView(A, I, sentinel)
_sentinelview(A::Union{SubArray,SentinelView}, I, sentinel) = SentinelView(parent(A), collect(sentinelview(only(parentindices(A)), I, sentinel)), sentinel)

end
