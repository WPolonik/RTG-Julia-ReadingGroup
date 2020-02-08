

#%% Arrays 
#%% ======================================================


#%% basic Array behavior
#%% ---------------------------------------------


#%% 1-d list
col   = [1, 2, 4.4, 6]

#%% rows are two dimensional
row   = [1  2  4.4  6]

#%% common Matlab construction of matrices
mat1  = [
    1    2
    4.4  6
]

#%% matrix of zeros
mat3  = zeros(10, 10)

#%% 3d array of zeros
zeros(3, 3, 2)


#%% general constructor with fill
fill(Float32(0), 10,10)
fill(0.0, 10,10)
fill(0, 10,10)


mat = fill(0, 5,5)
for cl=1:5, rw=1:5
	mat[rw,cl] = cl + rw 
end

mat = Array{Int64}(undef, 5,5)
for cl=1:5, rw=1:5
	mat[rw,cl] = cl + rw 
end


mat = Int64[]
for i=1:20 # rand([20, 200])
	j = i^2
	#push!(mat, i^2)
	global mat = vcat(mat, j)
end

mat = [1,2]
for i=1:5
	mat = vcat(mat, i^2)
end

function foo1(mat)
	for i=1:2
		mat = vcat(mat, i^2)
	end
	mat[1] = 0
	return mat
end

function foo2!(mat)
	for i=1:2
		mat[i] = i^2
	end
	return nothing
end

mat = [1,2]
foo1(mat)
mat 
foo2(mat)

#%% 10 x 10 matrix of random normals
mat2  = randn(10, 10)
mat2  = rand(10, 10)

#%% 1 based indexing, use mat[1,2] instead of mat(1,2)
mat2[1, 2] # first row, second column

mat2[1, :] # first row

#%% singular degenerate dimensions are removed
mat2[:, 2] # second column

mat2[end:-1:1, end-2:end] # second column


mat2[1:3, 7:end] # matrix sub block

mat2[:]  # stacks the columns

mat2[20] # linear indexing columnwise

#%% removing the 3rd row and 3rd column
Ind = vcat(1:2, 4:10)
mat2[Ind, Ind] 


#%% vectorization and broadcasting 
#%% ------------------------------------------------------
mat2 .^ 2 # .^ is coordinatewise power

#%% broadcasting
v = rand(100)
W = rand(100,100)
v + W # gives an error
v .+ W # repmats to match dimensions of W


#%% automatically vectories
exp.(mat2)


#%% foo.( automatically vectorizes and broadcasts this works for  function
mat_tmp = rand(10_000, 10_000)
foo(x) = exp(x) + sin(x) + x^4 +4*x
@time foo.(mat_tmp)

#%%
mat1 = rand(0:5, 10,10)
mat2 = rand(0:5, 10,10)
mat1 .* mat2 # coordinatewise mult

mat1 * mat2 # matrix mult


#%%
mat2 .<= 0

mat1 .<= mat2

#%% Arrays are mutable. Change elements
mat2[1,2] = 5
mat2

mat2[:,2] .= rand(size(mat2, 1)) # changing the second col
mat2


#%%  more on finding and changing elements
mat1 = rand(10,10)
mat2 = rand(10,10)
mat2[mat2 .<= mat1] .= -1
mat2

Ind = findall(mat2 .≥ 0) # returns a vector of linear columnwise indicies
@show mat2[Ind[1]], Ind[1]
@show mat2[Ind[2]], Ind[2]



#%% Linear Algebra is a standard library 
#%% ------------------------------------------------------
#%% Built in linear algebra (from BLAS and LPACK). 
using LinearAlgebra


#%% uniform scaling
mat1 = rand(10,10)
mat2 = π * I(10)

mat2 * mat1

#%% symmetric matrices 
sym_mat = Symmetric(m * m')


sym_mat * mat1
Symmetric(mat1)

#%%
Diagonal([1,2,3])

#%%
mat = rand(7,7) |> x -> x*transpose(x)
sym_mat = Symmetric(mat)

#%%
dv = eigen(mat)
dv.values
dv.vectors

#%%
dv_sym = eigen(sym_mat)
dv_sym.values
dv_sym.vectors


#%%
uv  = cholesky(sym_mat)
uv.L
@which uv.L

L = uv.L
y = rand(size(L,1))
x = L \ y 

@which L \ y
# @edit L\y


#%% FFTW on arrays 
#%% -------------------------------------------------------
using FFTW

m = rand(Float32, 2^14, 2^14)
FFTop = plan_rfft(m)
@time q = FFTop * m
@time FFTop \ q
@time FFTop \ q .- m





