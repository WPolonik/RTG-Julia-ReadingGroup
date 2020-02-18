



#' Basics
#' ==========================================

Sys.cpu_summary() #'
Sys.CPU_NAME #'
Sys.CPU_THREADS #'



using Distributed

#' this adds 3 new workers
addprocs(3)

#' workers returns the id numbers of the additional workers
#' the main julia julia session always has id==1, the others id==2,3,4 ...
workers()

#'
nworkers() # number of workers (excluding the master)

#'
nprocs() # number of workers (including the master)

#' If you want to close the workers use rmprocs(workers())
# workers() |> rmprocs

#' interrupt(2,3) or interrupt() or interrupt([2,3,4])
#' stops a computation on the works specified in the argument



#' @everywhere for defining stuff in Main on other workers
#' =========================================================
#' ```julia
#' help?> @everywhere
#' @everywhere [procs()] expr
#'
#'   Execute an expression under Main on all procs. Errors on any of the processes
#'   are collected into a CompositeException and thrown. For example:
#'
#'   @everywhere bar = 1
#'
#'   will define Main.bar on all processes.
#' ```

#' I mostly use `@everywhere` to import Modules on the workers and
#' to run top level code like function definitions setting global constants.
#' Here are some examples

@everywhere using InteractiveUtils
@everywhere function myfun1(x)
    y = (id=myid(), x=x, r=rand())
    print(y)
    return y = (id=myid(), x=x, r=rand())
end
@everywhere [1,2] begin
    a = 1
    b = 2
    const c = 3
end #' notice that worker 3 does not have these variables defined


@everywhere 2 varinfo() #' take a look at defs in worker2.Main
#' we can run myfun1(10) on worker2 and send the to worker1
out1 = @everywhere 2 myfun1(10)
#' if you run on multiple workers nothing is returned to worker1
@everywhere [2, 3] myfun1(10)


a #' ✅
@everywhere 2 a #' ✅
@everywhere 3 a #' ❌ ...gives an error
@everywhere 3 rand(c) #' ❌ ...gives an error

@everywhere 3 a=1 #' define these variables on worker3
@everywhere 3 b=2 #'
@everywhere 3 const c=3 #'
@everywhere 3 a #' ✅ ... now works
@everywhere 3 rand(c) #' ✅ ... now works


#' begin blocks just represent a chunck of code
#' which, when run in the REPL, behaves as though each line is
#' run sequentially at the REPL prompt (i.e. no new scope is introduced).
#' The last line of a begin block is returned

@everywhere 2 begin
    x = 1
    y = 2
    x + y
end

@everywhere 2 varinfo()
#' notice x and y are defined since begin doesn't start a new scope


#' let blocks
#' ---------------------------

#' Let blocks introduce a local scope. They can be used to evaluate code
#' as if it was put in a function. The last line is returned

@everywhere 2 let
    z = 1
    w = 2
    z + w
end

@everywhere 2 varinfo()
#' Notice that z and w are *not* defined since let starts a local scope


@everywhere 2 let
    z = 1
    w = 2
    z + w + x + y
end
#' Notice that x and y reach into global Main on worker 2


@everywhere 2 let x = 4, y = 2
    z = 1
    w = 2
    z + w + x + y
end
#' x and y are local variables

@everywhere 2 x + y
#' x and y in Main on worker 2 are undistrurbed.

@everywhere begin
    x = 5
    y = 10
end

@everywhere 2 varinfo()
@everywhere 3 varinfo()

@everywhere 2 x #' x is now 5 on worker2 and worker3
@everywhere 3 x


#' @spawnat,  Future and fetch for asynchronously evaluating expressions within functions
#' ====================================================================================
#' ```julia
#' help?> @spawnat
#' @spawnat p expr
#'
#'   Create a closure around an expression and run the closure asynchronously on process p. Return a Future to
#'   the result. If p is the quoted literal symbol :any, then the system will pick a processor to use
#'   automatically.
#'
#'   Examples
#'   ≡≡≡≡≡≡≡≡≡≡
#'
#'   julia> addprocs(3);
#'
#'   julia> f = @spawnat 2 myid()
#'   Future(2, 1, 3, nothing)
#'
#'   julia> fetch(f)
#'   2
#'
#'   julia> f = @spawnat :any myid()
#'   Future(3, 1, 7, nothing)
#'
#'   julia> fetch(f)
#'   3
#' ```

#' Run this if restartinga fresh Julia session
#=
using Distributed
addprocs(3)
@everywhere using InteractiveUtils
@everywhere begin
    a = 1
    b = 2
    const c = 3
    x = 5
    y = 10
end
=#

#' I use `@spawnat` and `fetch` within functions. Note: `@everywhere` is not suitable for this
#' since it won't ship local variables workers Main...  `@spawnat`does so it can be called within functions.
const d = 1

r = @spawnat 2 a + d
#' r is a Future which references a since computation on a remote worker.

#' fetch askes the worker who ran `r` to send it to the fetch caller.
#' fetch is a "sync" call so it will block till r has a value
fetch(r)

@everywhere 2 varinfo() #' Note that @spawnat shipped over d (unlike @everywhere).
@everywhere 3 varinfo() #' no d on worker3


@everywhere 3 d = 3


@everywhere 2 isconst(Main, :d) #' shipping by @spawnat preserves const
@everywhere 3 isconst(Main, :d)

let a = 0, d = 0
    fetch(@spawnat 3 a + d)
end
@everywhere 3 d # b doesn't change

#' To gard against accidentally shipping over and defining globals
#' you can use my alpha-status package LBblocks
#%%```
#%%julia> using Pkg
#%%julia> pkg"add https://github.com/EthanAnderes/LBblocks.jl#master"
#%%```

using LBblocks

@sblock let a = 0, d = 0
    fetch(@spawnat 3 a + d)
end

@sblock let a = 0
    fetch(@spawnat 3 a + d)
end #' ❌ ...gives an error since the body references d to global

#' without @sblock worker 2 will try to find d in global scope
let a = 0
    fetch(@spawnat 2 a + d)
end

#' what happens if you try to re-define `d` in a local scope with @spawnat
let
    fetch(@spawnat 3 (d=10;d^2))
end #'
@everywhere 3 d
#' So d is not re-defined in Main on worker 3.
#' Lets try the same with @everywhere

let
    @everywhere 3 (d=10;d^2)
end
@everywhere 3 d
#' Now d==10 on worker 3 since @everywhere always runs the code in workers Main.
#' This is why you shouldn't use @everywhere inside functions or local scope.



#' @async and @sync
#' ------------------------

#' It is important to note that @spawnat runs asynchronously if you don't immediately fetch the results
xs = let xs = Future[], njobs = 20
    for i = 1:njobs
        x = @spawnat :any begin
            tm = rand([1, 5])
            sleep(tm)
            "$(tm) from $(myid())"
        end
        push!(xs, x)
    end
    xs
end
fxs = fetch.(xs)
#' notice that the for-loop finished asynchronously, but
#' fetching the values waited till all the computations synchronized

#' You can force the loop to wait till everything is done with @sync


xs = let xs = Future[], njobs = 20
    @sync for i = 1:njobs
        x = @spawnat :any begin
            tm = rand([1, 5])
            sleep(tm)
            "$(tm) from $(myid())"
        end
        push!(xs, x)
    end
    xs
end
fxs = fetch.(xs)
#' Notice that the fetch was now able to grab the returned value immedately.



#' addprocs over multiple machines
#' ==========================================

#' killall julia
#' ps -u anderes

#' ----------------------
#' The steps you should take to make
#' sure Julia can connect without problems are the following (I will assume that
#' you are connected to gumbel):
#'
#'    ssh-keygen
#'
#' (just press ENTER until you return to the command prompt. This will set up a
#'  passwordless SSH key)
#'
#'    ssh-copy-id hilbert
#'
#' (this copies your SSH key into Hilbert's authorized_keys file. Make sure you
#' say yes if prompted to verify the authenticity of the host!)
#'
#' Now, you can add passwordless SSH to fisher as well:
#'
#'    ssh-copy-id poisson

####not sure if needed##### cat ~/.ssh/id_rsa.pub | ssh hilbert 'cat - >> authorized_keys'


machines = [("hilbert", 3), ("alan", 2)]
# addprocs(machines, tunnel=true, exename = "/usr/local/bin/julia-1.3.0",topology=:master_worker)
# addprocs(machines, tunnel=true, exename = "/usr/local/bin/julia-1.3.0",topology=:master_worker)
addprocs(
    machines,
    tunnel = true,
    exename = "julia-1.3.1",
    topology = :master_worker,
)

@everywhere println(pwd())

@everywhere using LinearAlgebra
@everywhere println(BLAS.vendor())
@everywhere println(versioninfo())



workers() |> rmprocs
