
Outline of notebooks in `Parallel/`
=========================================

* Notebook 1: `@everywhere`, `@spawnat`, `Future` and `fetch`
    - Macros that run code on workers
    - `@everywhere` for top level commands
    - `@spawnat` and `fetch` for local scope execution
    - `addprocs`, `rmprocs`, `nprocs`, `nworkers`, `interrupt`
    - `Sys.cpu_summary()`, `Sys.CPU_NAME`, `Sys.CPU_THREADS`   
    - `begin ... end` vrs `let ... end`
    - `LBblocks`
* Notebook 2: `remotecall`, `fetch` and `remotecall_fetch`
    - Functions that run closures on workers
    - MCMC chain example
    - `Distributed.nextproc()`


* Notebook 3: `remotecall`, `fetch` and `remotecall_fetch`
    - Building and running expressions
    - Finer control than with `@everywhere` and `@spawnat`
    - `isconst(Main,:b)`, `Meta.show_sexpr`, `dump`,, `macroexpand`, `@macroexpand`,, `parentmodule`, e.g. `parentmodule(dump) -> Base`,, `@code_lowered varinfo()`, `Meta.lower(m::Module, ex::Expr)`, `fullname(m::Module)`, e.g. `fullname(InteractiveUtils.Main) -> (:Main,)`, `functionloc(f::Function, ...arg types)`, `@functionloc varinfo()`, `Distributed.extract_imports(ex::Expr)`, `@__MODULE__`, `getfield`, `Core.eval`

* Notebook 4: `pmap`
    - A workhorse of quick and easy parallel
    - WorkerPool and Caching Pool For avoiding repeated passing of closures

* Notebook 5: `Channel` and `RemoteChannel` and `remote`
    - Containers used for dynamic scheduling










Other possibly useful packages
=========================================


* https://github.com/ChrisRackauckas/ParallelDataTransfer.jl
* ...
