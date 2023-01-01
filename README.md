# SentinelViews.jl

`sentinelview(X, I, [sentinel=nothing])`: like `view(X, I)`, but propagates `sentinel`.

```julia
A = [10, 20, 30]

Av = sentinelview(A, [1, 2, 3])  # equivalent to view(A, [1, 2, 3])
Av == [10, 20, 30]

Av = sentinelview(A, [1, nothing, 3])  # propagates nothing in indices to the result
Av == [10, nothing, 30]
```
