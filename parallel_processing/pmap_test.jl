# julia testing scripts
using Distributed
addprocs(20)
using LinearAlgebra

# array of matrices
# need max svd of each
M = Matrix{Float64}[rand(1000,1000) for i = 1:40];

println("Single Core")

@time results = map(x->maximum(svdvals(x)), M);

println("Multi-Core")
@time results = pmap(x->maximum(svdvals(x)), M);

println("fast Single Core")
@time results = map(x->getindex(svdvals(x),1), M);

println("Faster Multi-core")
@time results = pmap(x->getindex(svdvals(x),1), M);

