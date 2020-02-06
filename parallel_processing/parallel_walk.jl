# need to load-up the packages we'll need
using Distributed
using BenchmarkTools

# @sync & @async
# these are two macros that, in a sense, are inverses of each other

# let's check the documentation
# we an google it, or pull it up in Julia using @doc
@doc @sync
@doc @async

# it's not clear what these mean at first, so let's try some toy-examples
@time sleep(2)
# versus
@time @async sleep(2) 
# notice the time discrepancy
# the first one takes 2 seconds since Julia is waiting on sleep(2) to finish
# but @async tells Julia to continue processing immediately after sleep(2) is called
# and hence the @time is much smaller 

# now let's check out @sync
@doc @sync

# you can probably guess the output here
@time @sync @async sleep(2) 

# we need a more sophisticated example to see how @sync works

# but first, as an aside, let's quickly make our code parallel with addprocs() on our local machine

# If we aren't sure how many processors our local machine has, the following command is helpful
using Hwloc
Hwloc.num_physical_cores() # 

# the syntax couldn't be simpler
addprocs(1) # add 1 worker / separate Julia instance


# check the documenation
@doc addprocs

# checking the documenation we can see that the ouptput we got was the worker/processor ID 
# if we run this again, we an see that we get a new worker/processor ID
temp_proc = addprocs(1)

# we can check how many processors/workers we currently have
workers()

# we can remove the processor(s) by using the processor/worker ID
rmprocs(temp_proc)

# There is one "key line" towards the bottom
# "Note that workers do not run a .julia/config/startup.jl startup script, nor do they synchronize their 
#  global state (such as global variables, new method definitions, and loaded modules) with any of the other running processes.""

# We'll see some examples of what this means in a second

# Let's add another core and run the following toy-example
addprocs(1) # should have 2 workerss

# new function
cell(N) = Vector{Any}(undef, N) # vector of size N with type Any, initialized with 'undef'
# why 'undef'
# cell(1)[1] will give an error, instead of returning 'undef'

@time begin
    a = cell(nworkers()) # create an 
    for (idx, pid) in enumerate(workers())
        a[idx] = remotecall_fetch(sleep, pid, 2) # remotecall_fetch(function, process_id, input...) : make the call, wait for results.
    end
end

## 4.261763 seconds (63.86 k allocations: 3.270 MiB)

# this isn't working in parallel: each sleep has to wait for the one before to finish 
# but with @sync and @async 

@time begin
    a = cell(nworkers())
    @sync for (idx, pid) in enumerate(workers())
        @async a[idx] = remotecall_fetch(sleep, pid, 2)
    end
end
## 2.068824 seconds (2.51 k allocations: 145.204 KiB)
# now we are getting parallel: each iterate is scheduled without waiting for the previous to finish.

# note the scope of @sync and @async:
# @async is applied to the function call remotecall_fetch "and" storing the result to a[idx]
# @sync has scope over the entire loop. So Julia must wait for the loop to finish before continuing

# with @async; without @sync
@time begin
    a = cell(nworkers())
    for (idx, pid) in enumerate(workers())
        println("sending work to $pid")
        @async a[idx] = remotecall_fetch(sleep, pid, 2)
    end
end
a # will contain #undef (the results of remotecall_fetch haven't finished)
# if we wait 2 seconds, and check again after it finishes
a # should have nothing, nothing ; the result of  remotecall_fetch

# what about @async on the for loop itself?
@time begin
    a = cell(nworkers())
    @async for (idx, pid) in enumerate(workers())
        println("sending work to $pid")
        a[idx] = remotecall_fetch(sleep, pid, 2)
    end
end
# the whole loop runs without watiing 
# hence the @time is not 2 seconds
# but the loop itself is still sequential
# we will see worker 2 first, then 2 seconds later we will see worker 3

# @sync also relies heavily on what "complete" means (which depends on the functions used etc.)
# Example
@time begin
    a = cell(nworkers())
    @sync for (idx, pid) in enumerate(workers())
        @async a[idx] = remotecall(sleep, pid, 2) # only change; using remotecall() instead of  remotecall_fetch()
    end 
end
# @time results

# is our @sync broken? how come it's not waiting on the sleep results!?
# this is because remotecall() is complete, even though it's results haven't come back yet.
# remotecall_fetch() is only finished once the worker reports the task is complete.

# you can also tell the difference based on the output in a[]
a

# @spawnat : issues call to a specific worker and returns a Future result
# similar to remotecall()

x = @spawnat 2 randn(10)
fetch(x)

# using the :any expression, we can let Julia pick any available worker
y = @spawnat :any begin
   println(myid()) # see which worker is useds
  randn(5) 
end
fetch(y)

# @fetch : issues the call to :any worker waits for the output before continuing
z = @fetch begin
   println(myid()) # see which worker is useds
  randn(5) 
end
# same as fetch( @spawnat :any .... )

# @fetch with data movement
function method1()
    A = rand(100,100)
    B = rand(100,100)
    C = @fetch A^2 * B^2
end

function method2()
    C = @fetch rand(100,100)^2 * rand(100,100)^2
end

# compare them
@benchmark method1()
@benchmark method2()


# first method1() has to pass A & B to the worker first, then carry out the call
# method2() creates the matrix, locally, on the worker only.

## @distributed loops & pmap
# both @distributed & pmap carry out a loop in parallel
# but they are typically used for different parallel tasks
# @distributed : applying a "reducer" in parallel
# pmap : applying a given function, f, to each element of a collection

# @distributed
# checking the documenation we can see the specified usage in a for loop

@distributed [reducer] for var = range
     body
end

# lets do a 'heads-up' comparison

# serial version - count heads in a series of coin tosses
function add_serial(n)
    c = 0
    for i = 1:n
        c += rand(Bool)
    end
    c
end

# distributed version
function add_distributed(n)
    c = @distributed (+) for i in 1:n
        Int(rand(Bool))
    end
    c
end

@benchmark add_serial(10^6)
@benchmark add_distributed(10^6)

# here's another example


function foo(n)
    a = 0
    @distributed (+) for i in 1:n
        a += 1
    end
    a
end

a = foo(10) # what should the answer be

# Why does this go wrong?

function foo(n)
    a = 0
    @distributed (+) for i in 1:n ## the output of the reducer is not saved anywhere
        a += 1 # the increment is not on a, but the worker's copy of 'a', which then get reduced
    end
    a  # this is left unaltered by the previous steps
end

# @pmap

# we saw before the array function (think sapply in R): 
# map(f,c) : apply function f to each element of c

# pmap(f, "worker_pool", c): apply function f to each element of c using the pool of available workers.

# lets do a simple sanity check example
rmprocs(workers()); # get rid of any current workers
addprocs(20)

println("Single Core")
M = Matrix{Float64}[rand(1000,1000) for i = 1:40];
@time results = map(x->maximum(svdvals(x)), M);

println("Multi-Core")
# M = Matrix{Float64}[rand(1000,1000) for i = 1:40];
@time results = pmap(x->maximum(svdvals(x)), M);

println("fast Single Core")
# M1 = Matrix{Float64}[rand(1000,1000) for i = 1:40];
@time results = map(x->getindex(svdvals(x),1), M);

println("Faster Multi-core")
# faster version
# M = Matrix{Float64}[rand(1000,1000) for i = 1:40];
@time results = pmap(x->getindex(svdvals(x),1), M);

# so we can see that the parallel version is faster, but not by much
# note the extremely high number of allocations 
# 3.28 M  / 301.93 k \approx 11

# How do we interpet this?
# Is this just a problem of svdvals?
# What inefficiency is there?

# maximum is overkill here: svdvals() returns a sorted list, with the first element the largest
# so just get the first index will be a huge speed-up, and no memory required (finding the maximum searches the whole vector and has to allocate memory while doing so)
# alt. version
M = Matrix{Float64}[rand(1000,1000) for i = 1:40];
@time results = pmap(x->getindex(svdvals(x),1), M);

## additional addprocs(): multiple machines / servers

# addprocs() with ssh (adding workers on another machine)
# checking the @doc for addprocs shows that we can addprocs on another machine that 
#	i) we can passwordless ssh logon to
#	ii) has julia installed

# something that makes this streamlined (for general ssh usage) is setting up a ssh config file
# in the .ssh/ directory
# instead of typing ssh blandino@<server_name>.ucdavis.edu each time
# I can just type ssh <server_name>

# that will also work for Julia too!

# so the following command will work
addprocs(["blandino@hilbert"],exename="/usr/local/julia-1.3.0/bin/julia",tunnel=true,topology=:master_worker)
addprocs(["hilbert"],exename="/usr/local/julia-1.3.0/bin/julia",tunnel=true,topology=:master_worker) # using the config
# you can also specify how many procs you want as an additional argument
addprocs([ ("hilbert",2) ],exename="/usr/local/julia-1.3.0/bin/julia",tunnel=true,topology=:master_worker)

# the optional arguements:
#	exename = the version of the master process may be different from the worker process, and on a different directory
#	tunnel = sets up an SSH Tunnel for the connection 
#	topology = specifies how workers connect to each other (depends on how compute server is setup, security, etc.)


# sharedarrays
# package: SharedArrays
# create array shared across multiple workers


# distributsed arrays 
# from package DistributedArays
# creates an array distributed over many workers
# each has access to their local chunk


