
#' remotecall and fetch 
#' ==============================================================
#' `remotecall` is `@spawnat`'s big brother which 
#'  eats functions instead of expressions  or code.
#'
#' Here are the call signatures of the functions we will be looking at in this notebook
#'
#'   * remotecall(f::Function, id::Int, fargs...; fkwrds...) -> Future
#'   * wait(Future) -> Future (but key use is to block further exciution till Future value is available)
#'   * fetch(Future) -> value (get the value that Future is pointing to.
#'   * remotecall_fetch, remotecall_wait


using Distributed
addprocs(3)
@everywhere using InteractiveUtils



#' remotecall 
#' ------------------------------------------------------------------

#' ```julia
#' help?> remotecall
#'  remotecall(f, id::Integer, args...; kwargs...) -> Future
#'
#'  Call a function f asynchronously on the given arguments on the specified
#'  process. Return a Future. Keyword arguments, if any, are passed through to f.
#' ```

xs = let xs = Future[], njobs = 20
    @sync for i = 1:njobs
        f = () -> begin
            tm = rand([1, 5])
            sleep(tm)
            "$(tm) from $(myid())"
        end
        x = remotecall(f, Distributed.nextproc())
        push!(xs, x)
    end
    xs
end
fxs = fetch.(xs)



#' remotecall_fetch combines fetch and remotecall, syncronizing each call.
#'------------------------------------------------------------------

let
    f = n -> (r=rand(n), id=myid())
    a = remotecall_fetch(f, 2, 4)
    b = remotecall_fetch(f, 3, 1)
    a, b
end



#' wait and remotecall_wait 
#' ------------------------------------------------------------------
#' TODO: find a good example when this is most useful

# remotecall_wait(Core.eval, 2, Main, :(varinfo())) # no :b in namespace



#' LBblocks
#' ------------------------------------------------------------------
#' LBblocks that forces you to specify non-constant variables (@lblocks) and also constant variables
#' which are not modules or explicity declared functions (@sblocks).
#' Gives a slightly safer way to construct and ship closures


using LBblocks

@everywhere const bg = 2


# to avoid automatic transfer of constant variables to worker Main use
@sblock let ag=2.0, bg # bg needs to be declared or specified here
    f_abg = x -> sum(x) + ag + bg
    remotecall_fetch(f_abg, 3, 5.2)
end
@everywhere 2 (isdefined(Main, :bg), isconst(Main, :bg)


# to allow automatic transfer of constant variables to worker Main use
@lblock let ag=2.0
    f_abg = x -> sum(x) + ag + bg
    # bg is a constant global and will be moved to
    # worker 2 Main and declared constant there
    remotecall_fetch(f_abg, 3, 5.2)
end
@everywhere 2 (isdefined(Main, :bg), isconst(Main, :bg)
