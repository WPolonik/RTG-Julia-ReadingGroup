#'    • remotecall_fetch(Core.eval, pids, m::Module, ex::Expr)
#'			- on expressions
#'    • @everywhere [pid::Int] ex
#'         - equiv to Distributed.extract_imports(ex::Expr), then remotecall_fetch(Core.eval, pids, m::Module, ex::Expr)


using Distributed
using Distributed: nextproc
addprocs(3)
@everywhere using InteractiveUtils

#' remotecall_fetch and Core.eval
#' ==========================================

#' `Core.eval` is used to run "code" which is stored in a special AST (abstract syntax tree)
#' format in Julia `ex::Expr`.
#' ```julia
#' help?> Core.eval
#'   Core.eval(m::Module, expr)
#'
#'   Evaluate an expression in the given module and return the result.
#' ```

#' We can combine `remotecall_fetc` with `Core.eval` run code in Main on remote workers.
#' This perhaps gives finer control over @everywhere.


remotecall_fetch(Core.eval, 2, Main, :a) #'
remotecall_fetch(Core.eval, 2, Main, :(a=10)) #'
@everywhere 2 a #' this is 10



#' More on expressions
#' ==========================================


#%% run expressions on a worker in a module
#%% -----------------------------------------------
ex = :(varinfo())
typeof(ex)
dump(ex)
Meta.show_sexpr(ex)
rtn1 = remotecall_fetch(Core.eval, 2, Main, ex)
rtn2 = @everywhere 2 $ex #' you can "interpolate" expressions before the macro is called


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

#%% notice we have to wait for each remotecall_fetch
njobs = 8;
xs = String[]
for i in 1:njobs
    global xs
    push!(xs, remotecall_fetch(Core.eval, nextproc(), Main, ex))
end


#' You can do this asynchronously...
#' ... but warning: xs will get updated in the background
xs = String[]
for i in 1:njobs
    global xs
    @async push!(xs, remotecall_fetch(Core.eval, nextproc(), Main, ex))
end
xs
xs




#%% LBblocks and MacroTools for inspecting expressions
#%% -------------------------------------------------------
#%% LBblocks that forces you to specify non-constant variables (@lblocks) and also constant variables
#%% which are not modules or explicity declared functions (@sblocks).
#%% Install LBblocks via
#%%```
#%%julia> using Pkg
#%%julia> pkg"add https://github.com/EthanAnderes/LBblocks.jl#master"
#%%```

using LBblocks
using MacroTools

#%% To take a look at what @sblock does ...
ex = MacroTools.@expand @sblock let ag=bg, bg=ag, x
   return sum(x) + ag + bg
end

Meta.show_sexpr(ex)
ex.head
ex.args[1] # function definition
ex.args[2] # function call

ex.args[2].head # spcifies its a call
ex.args[2].args[1] # the function name
ex.args[2].args[2:end] # the function args


#' Some useful tools for working with expressions
#' ===============================================================
# `isdefined(Main, :b)` `isconst(Main,:b)`,
# `Meta.show_sexpr`, `dump`,, `macroexpand`, `@macroexpand`, MacroTools.expand,
# `parentmodule`, e.g. `parentmodule(dump) -> Base`,,
# `@code_lowered varinfo()`, `Meta.lower(m::Module, ex::Expr)`,
# `fullname(m::Module)`, e.g. `fullname(InteractiveUtils.Main) -> (:Main,)`,
# `functionloc(f::Function, ...arg types)`, `@functionloc varinfo()`,
# `@__MODULE__`, `getfield`
