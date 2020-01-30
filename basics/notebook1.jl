#%% You can convert this to a notebook with 
#%% ```
#%% julia> using Weave
#%% julia> convert_doc("notebook1.jl", "notebook1.ipynb")
#%% ```

#%% Julia Lang
#%% ==================================================================
#%% * Open source
#%% * High level matlab-like syntax
#%% * Fast like C (often one can get within a factor of 2 of C)
#%% * Made for scientific computing (matrices first class, linear algebra support, fft ...)
#%% * Modern features like:
#%%   - macros
#%%   - closures
#%%   - generated functions
#%%   - pass by reference
#%%   - OO qualities but done instead with multiple dispatch
#%%   - user defined types are just as fast as native types
#%%   - flexible modern package manager and with version enviroments
#%%   - parallelism and distributed computation out of the box
#%%   - powerful shell programming
#%%   - julia notebooks
#%%   - nearly system wide AD
#%%   - true threading
#%%   - code can be written in Unicode
#%%   	```
#%%   	julia> 😍 = √2
#%% 	1.4142135623730951
#%% 
#%% 	julia> 🤯 = 😍 + π
#%% 	4.555806215962888
#%% 	```
#%% * I can finally write fast loops (not to be underestaimted)
#%% * Since it is fast most of julia is written in julia. Also, since it is high level, the source is actually readable (and a good way to learn)
#%% * Julia interacts with python so well, any of the missing functionality can be called out to python


#%% Install 
#%% ==========================================================


#%% Basic installation and documentation can be 
#%% found at https://julialang.org
#%% 
#%% This wiki for documentation is also very good and 
#%% readable https://en.wikibooks.org/wiki/Introducing_Julia


#%% Once you have installed the julia app it will be useful to be able to launch
#%% it from the command line. To figure out the path do something like this in 
#%% your terminal
#%% ```shell
#%% ~ ❯❯❯ ls /Applications/Julia*/Contents/Resources/julia/bin/julia
#%% /Applications/Julia-1.3.1.app/Contents/Resources/julia/bin/julia
#%% ```
#%% 
#%% Now create an alias to that path by running (or adding to `.bash_profile` or `.zshrc`)
#%% ```
#%% alias julia="/Applications/Julia-1.3.1.app/Contents/Resources/julia/bin/julia"
#%% ```
#%%
#%%  and/ or  
#%%  
#%% ```
#%% export PATH="/Applications/Julia-1.3.1.app/Contents/Resources/julia/bin/:$PATH"
#%% ```



#%% If your using the editor Juno ... here are some tips (key maps on a mac)
#%% run cell and move down: option-enter or alt-enter
#%% move to cell: alt-up or alt-down
#%% run line and move down: shift-enter
#%% run selected code: cmd-enter




#%% Quick Start
#%% ==========================================================
#%% for the demo run these commands in the Julia REPL...

a  = 1 + sin(2)
b  = rand(15) # 15 uniform random numbers
c  = randn(5,5) # a 5x5 matrix of standard normals
Σ² = c * a * π
varinfo()

#%% 
using Statistics: mean, std # just import functions mean and std into global scope
mean(c)
std(c)

#%% 
rand(1:10,25) # 25 draws with replacement from 1,2,3,..., 10

#%% 
x = rand(1000, 1000)
y = randn(1000, 1000)
z = Array{Float64,2}(undef, 1000, 1000) # initialize an empty array

foo(x) = (x^2)/2 # one line function definition


for i in eachindex(z) #
    z[i] = log(x[i] + 1) - foo(sin(2 * y[i]))
end

w  = log.(x .+ 1) .- foo.(sin.(2 .* y)) # this is a fuzed loop creating a new variable
z .- w

pointer(w)
w .= log.(x .+ 1) .- foo.(sin.(2 .* y)); # this is a fuzed mutating loop
pointer(w)

#%%  macros
@time log.(x .+ 1) .- foo.(sin.(2 .* y));

#%%  benchmarking macro 
using BenchmarkTools
@benchmark log.(x .+ 1) .- foo.(sin.(2 .* y))


#%%  run a file of julia source
#%% ```
#%% julia> include("run.jl")
#%% ```

#%%  exit REPL
# julia> exit()

#%%  To uninstall, just remove binaries (this should just be one directory) and ~/.julia/


#%% 
#%% install 3rd party packages hosted on github.
#%% these are saved in ~/.julia/
#%% ```
#%% julia> using Pkg
#%% julia> pkg"add Distributions"
#%% ```

#%% load a package into a session
using Distributions
X = Beta(1/2, 1/2) # X is a Beta random variable
fieldnames(typeof(X))
rand(X, 10) # 10 random draws from X
mean(X) # overloaded by Distributions
var(X)  # -> (α * β) / ((α + β)² * (α + β + 1))
# @edit var(X)
# @edit mean([1,2,3])
# @edit mean(X)


#%% 
# shell mode by typing ;
# julia>; pwd
# julia>; cd ..
# julia>; ls

# package manager repl by typing ]
# julia>] st

# help mode by typing ?
# julia>? sum

apropos("determinant")

#%%  Easiest simplist plotting
using UnicodePlots: lineplot, lineplot!, scatterplot, histogram, densityplot
x=range(0,2π, length=1000)
lineplot(x,sin.(x))
scatterplot(randn(50), randn(50))
histogram(randn(1000) * 0.1, nbins= 20)
densityplot(randn(1000), randn(1000))


#%%  
using SpecialFunctions: besselk # Modified Bessel function of the second kind of order nu
x=range(0,5, length=1000)[2:end]
ν = 3/2
y = x.^ν .* besselk.(ν, x)
plt1 = lineplot(x,y, name="ν = 3/2", xlabel= "x")
ν = 1/2
y = x.^ν .* besselk.(ν, x)
lineplot!(plt1, x, y, name="ν = 1/2")



#%%  Design Philosophy: multiple dispatch and type stability
#%% =================================================================

#%%  Type tree
typeof(4)

typeof(4.0)

typeof(4//7)

typeof(rand(101,10)) # 2-d array of floats

typeof([1, 2, 3]) # 1-d array of ints

# types have types
typeof(Float64) # convention, types start with capital letter

# dynamic typing
a = 4
typeof(a)

a = 1.0
typeof(a)

# You can move up tree with super
supertype(Int64)

supertype(Int64) |> supertype

supertype(Int64) |> supertype |> supertype

supertype(Int64) |> supertype |> supertype |> supertype

supertype(Int64) |> supertype |> supertype |> supertype |> supertype # at the top of the tree we have Any

# You can move down the tree with subtypes
subtypes(Real)

subtypes(AbstractArray)

# check if a type is an ancestor
Real <: Number

Real <: AbstractArray



#%%  JIT, multiple dispatch and Type stability 

#%% I'm defining 4 different versions of foo
function foo(x::Float64, y::Float64)
    println("foo(Float64, Float64) was called")
    return round(Int64, x * y)
end

function foo(x::Real, y::Real)
    println("foo(Real, Real) was called")
    return round(Int64, x * y)
end

function foo(x::Integer, y::Integer)
    println("foo(Int, Int)  was called")
    x * y
end

function foo(x, y) # fall back
    println("fall back was called")
    x .* y
end

function foo(x)
    println("f(x,x) was called")
    foo(x, x)
end

#%% 
foo(1, 1)

foo(2.0, 1)

foo(2.0, 4.9)

foo(2.0)

foo(randn(15, 15))

methods(foo) # lists all the possible call signatiures

a = 2
@time foo(a); # warm up Jit compile
@time foo(a); # now we are using the Jit


function baz() # not type stable
    cntr = 0        # starts as as int
    x = [-1, -1, 2]
    for i = 1:length(x)
        if x[i] > 0
            cntr += 1.0 # depending on the run time values  might promote to a float
        end
    end
    return cntr
end


function baz(x) # not type stable
    cntr = 0        # starts as as int
    for i = 1:length(x)
        if x[i] > 0
            cntr += 1.0 # depending on the run time values  might promote to a float
        end
    end
    new_cntr = Int64(cntr)
    return new_cntr
end

function boo(x) # type stable
    cntr = 0.0        # same type as x entries 
    for i = 1:length(x)
        if x[i] > 0
            cntr += 1.0 # stays a float
        end
    end
    return cntr
end


a = rand(10_000_000)
@time baz(a);
@time baz(a);
@time boo(a);
@time boo(a);

#%% check what types julia infers
@code_warntype baz(a)

@code_warntype boo(a)


#%% the parsed type infered AST
@code_lowered baz(a)

@code_lowered boo(a)


#%% the llvm output
@code_llvm baz(a)

@code_llvm boo(a)



#%% the machine code
@code_native baz(a)

@code_native boo(a)




#%%  multiple dispatch in action 
#%% ========================================================
using Distributions

x = rand(10)
mean(x), std(x)  # functions in Statistics Julia

λ, α, β = 5.5, 0.1, 0.9
xrv = Beta(α, β) # creats an instance of a Beta random variable
yrv = Poisson(λ) # creats  an instance of a Poisson
zrv = Poisson(λ) # another instance
typeof(xrv), typeof(yrv), typeof(zrv)

#%% mean is overloaded to give the random variable expected value.
mean(xrv)  # expected value of a Beta(0.1, 0.9)

#%% std is overloaded to give the random variable standard deviation
std(zrv)   # std of a Poisson(5.5)

#%% rand is overloaded to give random samples from yrv
rand(yrv, 10)  # Poisson(5.5) samples

@which mean(xrv) # check which method is called

# @edit mean(xrv)

#%% If you have Julia source you can go directly to code
#%% This is particularly useful when debugging (you can read the source to see what is going wrong)
mean(["hi"])

#%% Lets see where the definition of mean to see what is going wrong
# edit("statistics.jl", 157)


#%% a few fun extras 
#%% ====================================================

#%%  easiy multiple assignment
a, b, c = 1, 2, 3
b

#%%  piping
a = sin(cos(exp(5)))
b = 5 |> exp |> cos |> sin
a == b

#%%  un-named functions, i.e. lambda functions from python
y = 1.9 |> cos |> x->dot(x,x) |> x -> sin(x^2) |> log

#%%  indexing can happen at the end
a = (rand(10, 10) * rand(10, 10))[2, 2]

#%%  string interpolation is easy
a = 5
"The variable a is assigned the value $a."

a = "ethan"
"The variable a is assigned the value $a."

for a ∈ ["baz", "boo", "bar"] # loop over a vector of strings
    println("The variable a is assigned the value $a")
end

#%%  dictionaries
a = Dict("bar" => 10, "baz" => 5, "boo" =>1)

a["baz"]

#%%  immutable tuples
tul = (4, 5, 6)
tul[2]

tul[2] = 7 # error

#%%  sets
As= Set([2,3,4,4,5,6])
4 ∈ As





#%% loops 
#%% ==========================================

#%% for loops
A = fill(0, 10,10) # initialized 10x10 array of 0's
for i = 1:10
    for j ∈ 1:10
        A[j, i] = i + j
    end
end
A


#%% equivalent
for i in 1:10, j ∈ 1:10
    A[j, i] = i + j
end
A




#%% conditionals
#%% ==========================================

x = 2
if x == 5
    print(1)
else
    print(2)
end




#%% comprehensions 
#%% ==========================================

#% comprehensions for quick construction of Arrays
[sin(x) for x = 1:3]

#%% for matrix construction
[abs(i - j) for i = [4, 7, 8], j = 1:3]

#%% flatten to 1 -d
[abs(i - j) for i = [4, 7, 8] for j = 1:3]

#%% flatten with conditionals
[abs(i - j) for i = [4, 7, 8] for j = 1:3 if i-j > 2]

#%% preserving shape
mat = rand(5,5)
[x^2 for x in mat]

#%% not preserving shape
[x^2 for x in vec(mat)]

#%% prepend the comprehension to inform the type of the array
a = Float32(1.0)
typeof(a)
typeof(2*a)
Float64[a*k for k ∈ 1:5]
Float32[a*k for k ∈ 1:5]

#%%
vecv = Array{Float64,1}[rand(i) for i=1:10]

#%% `Vector{T}` is shorthand for `Array{T,1}`
#%% `Vector` is shorthand for `Array{T,1} where T`

matv = Vector[rand(i+j) for i ∈ 1:10, j ∈ 2:5]

#%% generaters 
#%% ========================================================
A = rand(10_000)
@time sum(exp.(A) .+ sin.(A) .+ cos.(A))
@time sum(exp(a) + sin(a) + cos(a) for a in A)



#%% shell scripting
#%% ========================================================

for ν in [0.8, 1.2, 2.2], ρ in [0.05, 0.2], xmax in [1.2, 1.4]
    # run(`julia scripts/script1d/script1d.jl $ν $ρ $σ $prdc_sim $xmax`)
    @show `julia scripts/script1d/script1d.jl $ν $ρ $xmax`
end

# ρ = [0.05, 0.2]
# xmax = [1.2, 1.4]
# `julia ρ = $ρ, xmax=@xmax`

#%% closures
#%% ========================================================

function clos(data)
    # withing the function scope, data acts like a global variable
    function loglike(μ)
        -0.5 * sum(abs2, data .- μ)
    end
    function updatedata(val)
        push!(data, val)
    end
    loglike, updatedata # return the two functions
end

like1, updatedata1 = clos(rand(10))
# now the data is closed off to any mutations other than
# those given by updatedata


[like1(μ) for μ=0.1:.1:3] |> x -> plot(0.1:.1:3, x)

updatedata1(10) # add 10 to the data set

[like1(μ) for μ=0.1:.1:3] |> x -> plot(0.1:.1:3, x)

#%% closures are useful for making passing a likelihood function to an optimization package








#%%  some useful packages 
#%% ========================================================

#%% PyPlot
#%% ----------------------------------------------------
using PyPlot
x = sin.(1 ./ range(.05, 0.5, length=1_000))
plot(x, "r--")
title("My Plot")
ylabel("red curve")

figure()
imshow(rand(100,100))


##  PyCall Spatial Interpolation (compare with python code)
#%% ----------------------------------------------------
using PyCall
scii = pyimport("scipy.interpolate")

function f(x, y)
    s = hypot(x, y)
    phi = atan(y, x)
    tau = s + s*(1-s)/5 * sin(6*phi) 
    return 5*(1-tau) + tau
end

# These are the non-uniform spatial points we have f observed on 
npts = 400
px   = 2 .* rand(npts) .- 1
py   = 2 .* rand(npts) .- 1
pf   = f.(px, py)

# This the spatial grid of points we want to interpolate 
nxgrid = 200
nygrid = 200
X = range(-1,1,length=nxgrid)  .+ fill(0, nxgrid, nygrid) 
Y = range(-1,1,length=nygrid)' .+ fill(0, nxgrid, nygrid) 

# 2-d interpolation of irregular spatial locations
griddata = scii.griddata

# Here is the interpolation
fn = griddata((px, py), pf, (X, Y), method="nearest")
fl = griddata((px, py), pf, (X, Y), method="linear")
fc = griddata((px, py), pf, (X, Y), method="cubic")

# plot it...
fig, ax = subplots(nrows=2, ncols=2)

ax[1,1].contourf(X, Y, f.(X, Y))
ax[1,1].scatter(px, py, c="k", alpha=0.2, marker=".")
ax[1,1].set_title("Sample points on f(X,Y)")

for (method,finterp,rc) ∈ zip(("nearest","linear","cubic"), (fn, fl, fc),((1,2),(2,1),(2,2)))
	ax[rc[1],rc[2]].contourf(X, Y, finterp)
	ax[rc[1],rc[2]].set_title("method = $method")
end

tight_layout()



#%% from 
#%% https://scipython.com/book/chapter-8-scipy/examples/two-dimensional-interpolation-with-scipyinterpolategriddata/
py""" 
import numpy as np
from scipy.interpolate import griddata
import matplotlib.pyplot as plt

x = np.linspace(-1,1,100)
y =  np.linspace(-1,1,100)
X, Y = np.meshgrid(x,y)

def f(x, y):
    s = np.hypot(x, y)
    phi = np.arctan2(y, x)
    tau = s + s*(1-s)/5 * np.sin(6*phi) 
    return 5*(1-tau) + tau

T = f(X, Y)
# Choose npts random point from the discrete domain of our model function
npts = 400
px, py = np.random.choice(x, npts), np.random.choice(y, npts)

fig, ax = plt.subplots(nrows=2, ncols=2)
# Plot the model function and the randomly selected sample points
ax[0,0].contourf(X, Y, T)
ax[0,0].scatter(px, py, c='k', alpha=0.2, marker='.')
ax[0,0].set_title('Sample points on f(X,Y)')

# Interpolate using three different methods and plot
for i, method in enumerate(('nearest', 'linear', 'cubic')):
    Ti = griddata((px, py), f(px,py), (X, Y), method=method)
    r, c = (i+1) // 2, (i+1) % 2
    ax[r,c].contourf(X, Y, Ti)
    ax[r,c].set_title("method = '{}'".format(method))

plt.tight_layout()
plt.show()
"""

py"npts"

#%% PyCall UnivariateSpline
#%% ----------------------------------------------------
using PyCall
scii = pyimport("scipy.interpolate")
x = 1:10
y = sin.(x) .+ rand(10) ./ 5
iy = scii.UnivariateSpline(x, y, s = 0) # python object

# here is all the stuff in iy
keys(iy)

yinterp(x) = iy(x) # the function behavior in Python behaves the same in Julia
xnew = range(2, 9, length=1000)
figure()
plot(xnew, yinterp(xnew))
plot(x, y,"r*")

