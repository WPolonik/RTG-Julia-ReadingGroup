

using Random: shuffle
using Distributed
import Distributed: rmprocs
addprocs(2)

#%% this is just to be able to run varinfo on all workers
@everywhere using InteractiveUtils

#%% easy removal of all jobs
rmprocs() = rmprocs(workers())

function wrkplan(njobs::Int, wrker_list::Vector{T}) where T<:Int
    vec_rng = Distributed.splitrange(njobs, length(wrker_list))
    schdl   = Int[]
    for (wrker, rng) = zip(wrker_list, vec_rng)
        schdl = vcat(schdl, fill(wrker,length(rng)))
    end
    return shuffle(schdl)
end


#%% remotecall_fetch
#%% ===============================================

#%% run expressions on a worker in a module
#%% -----------------------------------------------
ex = :(varinfo())
typeof(ex)
dump(ex)
rtn = remotecall_fetch(Core.eval, 2, Main, ex)
rtn


#%% run expressions on a worker in a module
#%% -----------------------------------------------
ex = quote
    x = rand()
    "$x from $(myid())"    
end
remotecall_fetch(Core.eval, 1, Main, ex)
remotecall_fetch(Core.eval, 2, Main, ex)
remotecall_fetch(Core.eval, 3, Main, ex)

remotecall_fetch(Core.eval, 1, Main, :x)
remotecall_fetch(Core.eval, 2, Main, :x)
remotecall_fetch(Core.eval, 3, Main, :x)

remotecall_fetch(Core.eval, 1, Main, :(x=1))
remotecall_fetch(Core.eval, 2, Main, :(x=2))
remotecall_fetch(Core.eval, 3, Main, :(x=3))

remotecall_fetch(Core.eval, 1, Main, :x)
remotecall_fetch(Core.eval, 2, Main, :x)
remotecall_fetch(Core.eval, 3, Main, :x)


#%% run expressions on a worker in a module
#%% -----------------------------------------------
ex = quote
    sleep(rand([1,5]))
    "$(rand()) from $(myid())"    
end

#%% notice we have to wait 
xs = String[]
njobs = 8;
schdl = wrkplan(njobs,workers()) 
# schdl = [2,3,2,3,2,3,2,3]
for i in schdl
    global xs
    push!(xs, remotecall_fetch(Core.eval, i, Main, ex))
end


#%% use @async launch these jobs simultaniously, but xs gets updated in the background
xs = String[]
for i in schdl
    global xs
    @async push!(xs, remotecall_fetch(Core.eval, i, Main, ex))
end


#%% use @sync on the for loop to wait till all the iterations have finished
xs = String[]
@sync for i in schdl
    global xs
    @async push!(xs, remotecall_fetch(Core.eval, i, Main, ex))
end
#%% note the ordering of xs and that there are exactly 4 from worker 3 and 2



#%% Another call signature of remotecall_fetch
#%% -----------------------------------------------

#%% Globals in closures are shipped over to worker Main (mirroring constants)
#%% Note that generalized function 
# remotecall_fetch(f, id::Integer, args...; kwargs...)

const ag = 1.0
const bg = 1.0

f_ag = x -> sum(x) + ag 
f_ag(5.2)
remotecall_fetch(f_ag, 2, 5.2)

#%% Now ag is defined as in Main at worker==2
remotecall_fetch(Core.eval, 2, Main, :(varinfo()))

#%% Also ag is defined as constant in Main at worker==2
consts_ex = quote 
    [s for s in names(Main) if isconst(Main,s)]
end
remotecall_fetch(Core.eval, 2, Main, consts_ex)


#%% You can over-ride this behavior by decoupling 
#%% the reference to ag with a let block 
let ag=2.0
    f_ag = x -> sum(x) + ag 
    remotecall_fetch(f_ag, 2, 5.2)
end


#%% this works nicely with LBblocks that forces you to 
#%% specify non-constant variables (@lblocks) and also constant variables 
#%% which are not modules or explicity declared functions (@sblocks)
using LBblocks

# to avoid automatic transfer of constant variables to worker Main use 
@sblock let ag=2.0, bg # bg needs to be declared or specified here
    f_abg = x -> sum(x) + ag + bg 
    remotecall_fetch(f_abg, 2, 5.2)
end
remotecall_fetch(Core.eval, 2, Main, consts_ex)

# to allow automatic transfer of constant variables to worker Main use 
@lblock let ag=2.0
    f_abg = x -> sum(x) + ag + bg 
    # bg is a constant global and will be moved to 
    # worker 2 Main and declared constant there
    remotecall_fetch(f_abg, 2, 5.2)
end
remotecall_fetch(Core.eval, 2, Main, consts_ex)



#%% TODO
#%%
#%% 1. use workerpool to dynamically schedule jobs when available 
#%% 2. threads
#%% ```
#%% function foo2!(x, y)
#%%     Threads.@threads for i in eachindex(y) 
#%%        y[i] = 2 * cos(sin(x[i]))
#%%    end
#%% end
#%% ```

#%%
#%% Questions

#%% 1. what else can I put in place of Core.eval
#%% 2. Globals in closures are shipped over to worker Main (mirroring constants)  
#%%    but this does not work for functions? Why and how to differentiate these variables
