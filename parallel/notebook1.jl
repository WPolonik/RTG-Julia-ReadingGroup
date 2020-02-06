
#%% Some lo


using Distributed
import Distributed: remotecall_eval
import Distributed: rmprocs
addprocs(2)

#%% this is just to be able to run varinfo on all workers
@everywhere using InteractiveUtils

#%% easy removal of all jobs
rmprocs() = rmprocs(workers())


#%% remotecall_fetch
#%% ===============================================

#%% run expressions on a worker in a module
#%% -----------------------------------------------
ex = :(varinfo())
typeof(ex)
dump(ex)
rtn = remotecall_fetch(Core.eval, 2, Main, 
    ex
)
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

remotecall_fetch(Core.eval, 1, Main, :(x))
remotecall_fetch(Core.eval, 2, Main, :(x))
remotecall_fetch(Core.eval, 3, Main, :(x))

remotecall_fetch(Core.eval, 1, Main, :(x=1))
remotecall_fetch(Core.eval, 2, Main, :(x=2))
remotecall_fetch(Core.eval, 3, Main, :(x=3))

remotecall_fetch(Core.eval, 1, Main, :(x))
remotecall_fetch(Core.eval, 2, Main, :(x))
remotecall_fetch(Core.eval, 3, Main, :(x))


#%% run expressions on a worker in a module
#%% -----------------------------------------------
ex = quote
    sleep(rand([1,5]))
    "$(rand()) from $(myid())"    
end

#%% notice we have to wait 
xs = String[]
for i=[2,3,2,3,2,3,2,3]
    global xs
    push!(xs, remotecall_fetch(Core.eval, i, Main, ex))
end


#%% use @async launch these jobs simultaniously, but xs gets updated in the background
xs = String[]
njobs = 8; 
wrkrplan = splitrange(njobs, length(workers())) # or something like wrkrplan = [2,3,2,3,2,3,2,3]
for i in wrkrplan
    global xs
    @async push!(xs, remotecall_fetch(Core.eval, i, Main, ex))
end


#%% use @sync on the for loop to wait till all the iterations have finished
xs = String[]
@sync for i in wrkrplan
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



#%% this works nicely with LBblocks
using LBblocks
@lblock let ag=2.0
    f_abg = x -> sum(x) + ag + bg 
    # bg is a constant global and will be moved to 
    # worker 2 Main and declared constant there
    remotecall_fetch(f_abg, 2, 5.2)
end
remotecall_fetch(Core.eval, 2, Main, consts_ex)



[s for s in names(Main) if isconst(Main,s) && !isa(Main.s,Function)]


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
