#' PkgTemplates for quick generation of a julia package 
#' ====================================================================
#' 
#' One of the reasons I love this package is that it allows me to quickly start 
#' a Julia package for even short side projects. Since a Julia package is basically just 
#' a directory structure that contains a few bare bones files it's easy to mangage. There are a 
#' number of advantages to doing all your probjects in pacakges. Here are just a few:
#' 
#' * A julia file will have a Manifest.toml file that records the exact state of 
#' all your imported packages. After you finish your code and it sits around on your computer 
#' for a number of years, you can "activate" your Manifest file and generate a local environment 
#' that reproduces the exact state of the packages you had used when writing your project. This 
#' environment doesn't modify your current packages so your julia setup will return to 
#' normal after exicting the REPL session. The net effect of this is that you can run really old code 
#' that would normally have long since broken due to updates and API changes. 
#' 
#' * A just package comes automatically with a testing file that encouranges you 
#' to add unit tests as your work on your script or project. 
#' 
#' * Also a package encourages you to keep putting functions in a module, rather than 
#' directly in a script file. This is the proper way to do things but feels hard if your 
#' starting with a script and then post-hoc need to create a module to hold your new methods/functions. 
#' 
#' ### Note:
#'
#' If you want to link your package to a github repo you need to initialize the 
#' repo on github before you push it up to github.com (on the github webpage select 
#' the option that doesn't setup an initial README.m etc.
#' when you initialize the project). 
#' 
#' ### Note:
#'
#' The following code for using PkgTemplates assumes you have the relatively 
#' standard Git options `user.name`, `user.email` and `github.user` set up on 
#' your machine. If not, just do something like this:
#' ```shell
#' git config --global user.name "Ethan Anderes"
#' git config --global user.email "anderes@ucdavis.edu"
#' git config --global core.editor "subl -n -w"
#' git config --global github.user "EthanAnderes"
#' ```
#' 
#' If you having problems with the git credentials try
#' `git credential-osxkeychain erase`
#' 



#' For now we use the development version of PkgTemplates
#' -----------------------------------------------------

using Pkg 
add"add PkgTemplates#master"




#' Put this in `~/.julia/config/startup.jl
#' -----------------------------------------------------

#' So that you can quickly generate a new package add this to your startup file.
"""
```
t = template(; curr_dir::Bool = true)
```
This loads a basic template for generating packages with `PkgTemplates.jl`. 
If your happy with the defaults the simplest way to run it is as follows
```
julia> using PkgTemplates
julia> t=template()
julia> t("PkgName")
```

### Options
* Set `curr_dir=false` if you want your package directory to be stored in `~/.julia/dev`. 

### Code loading without adding to environment

To load `PkgName` in the REPL, i.e. run  `julia> import PkgName` 
or `julia> using PkgName`, without adding `PkgName` to the 
default pkg environment you have two options. 

* Option 1:  
```julia
shell> cd <path to PkgName dir> 
pkg> activate . 
``` 
* Option 2:
```julia 
pkg> activate <path to PkgName dir>
``` 

### Code loading by adding `PkgName` to environment

Add `PkgName` to an environment 
```julia
pkg> dev <path to PkgName dir> 
```
This only needs to be done once. Then whenever/wherever julia is launched
`julia> import PkgName` or `julia> using PkgName` will work.

"""
function template(; curr_dir::Bool = true)
	gitplug = Git(
		ignore   = String[
			"local", # local directory that is ignored by git
			"*.jld",
			"*.jld2",
			"*.fits",
			"*.aux",
			"*.bbl",
			"*.aux",
			"*.blg",
			"*.fdb_latexmk",
			"*.log",
			"*.synctex.gz",
			"*.fls",
			"*.jl.cov",
			"*.jl.*.cov",
			"*.jl.mem",
			"*.DS_Store",
		],
		ssh      = false, 
		manifest = true, 
	)
    # if dev 
    # 	plugins = PkgTemplates.Plugin[gitplug, Develop()]
    # else 
    	plugins = PkgTemplates.Plugin[gitplug]
    # end
    return Template(; 
		dir     = curr_dir ? pwd() : "~/.julia/dev",
		julia   = v"1.3",
		plugins = plugins,
    )
end



#' I'll use this for a generating project directory in one of my courses
#' -----------------------------------------------------

using PkgTemplates
t = template()
t("Project_Gaussian1")

#' This creates `Project_Gaussian1/` in the current directory which has 
#' files `LICENSE`, `Manifest.toml`, `Project.toml, README.md`, `.gitignore` 
#' and directories `src/` and `test/`



#' `src/`
#' -----------------------------------------------------
#'
#'
#' There is only one file in `src/` which has the same name as your package name.
#' In my case it is `src/Project_Gaussian1.jl`. 
#' This defines the module and is where you put your code. It should look like 
#' this
#'
#' ```julia
#' module Project_Gaussian1
#' 
#' # Write your package code here.
#' 
#' end
#' 
#' ```
#'
#'
#' Lets add some code to it and see how to run it. 
#' Modify `src/Project_Gaussian1.jl` 
#' to read
#'
#'
#' ```julia
#'  module Project_Gaussian1
#'  
#'  export hi, bye
#'  
#'  const module_dir  = joinpath(@__DIR__, "..") |> normpath
#'
#'  hi() = "hey"
#'  
#'  """
#'  ```
#'  bye() -> "later"
#'  ```
#'  Used for testing
#'  """
#'  bye() = "later"
#'  
#'  end
#' ```
#'
#'


#' Now launch a new julia session 

using Project_Gaussian1
hi()
bye()
Project_Gaussian1.module_dir
@doc bye()


#' Suppose you want to add some other package dependencies to `Project_Gaussian1`.
#' First you need to do this 
#'
#' ```julia 
#' (@v1.4) pkg> activate .
#' (Project_Gaussian1) pkg> add LinearAlgebra
#' (Project_Gaussian1) pkg> add PyPlot
#' (Project_Gaussian1) pkg> resolve
#' (Project_Gaussian1) pkg> activate 
#' (@v1.4) pkg> 
#' ```
#' 
#' The following lines of code do the same thing 

using Pkg 
pkg"activate ."
pkg"add LinearAlgebra"
pkg"add PyPlot"
pkg"resolve"
pkg"activate"


#' Then add 
#' ```julia 
#' using LinearAlgebra
#' using PyPlot
#' ```
#' to `src/Project_Gaussian1.jl`. I prefer to write these lines just after the 
#' module definition but before the explort list 
#'
#'
#' Now you should be able to use functions/methods from LinearAlgebra and PyPlot within 
#' your package.



#' Set up git 
#' -----------------------------------------------------

#' Now initialize a git repo in `Project_Gaussian1`.

```
git init
git add --all
git commit -m "message"
```

#' Note: If you have a github repo you want to push up to you'll need 
#' to connect with git remote ...


#' Testing
#' -----------------------------------------------------
#' Here is what your file `test/runtests.jl` should look like
#' 
#' ```julia
#' using Project_Gaussian1
#' using Test
#' 
#' @testset "Project_Gaussian1.jl" begin
#'     # Write your tests here.
#' end
#' ```
#'
#' Lets modify it a bit
#'
#' ```julia
#' using Project_Gaussian1
#' using Test
#' 
#' @testset "basic 1" begin
#'     @test hi() == "hey"
#' end
#' 
#' @testset "basic 2" begin
#'     @test bye() == "later"
#' end
#' ```

#' Now launch a fresh julia session and you should be able to do something like this 
#'
#'
#' ```julia
#' (@v1.4) pkg> activate Project_Gaussian1
#'  Activating environment at  ...
#' 
#' (Project_Gaussian1) pkg> test
#'     Testing Project_Gaussian1
#' Status ...
#'   [3da002f7] ColorTypes v0.9.1
#'   [5ae59095] Colors v0.11.2
#'   [34da2185] Compat v2.2.0
#'   [8f4d0f93] Conda v1.4.1
#'   ⋮	
#' 
#' Test Summary: | Pass  Total
#' basic 1       |    1      1
#' Test Summary: | Pass  Total
#' basic 2       |    1      1
#'     Testing Project_Gaussian1 tests passed
#' 
#' (Project_Gaussian1) pkg>
#' ```
#'
#' Equivalently you can do this 

using Pkg 
pkg"activate Project_Gaussian1"
pkg"test"



#' Manifest.toml and Project.toml files
#' -----------------------------------------------------

#'  When you added the packages `LinearAlgebra` and `PyPlot` by 
#'  activating the environment of `Project_Gaussian1` two things happened. 
#'  
#'  (1) The names and unique identifiers (uuid's) of LinearAlgebra and PyPlot got 
#'  	added to Project.toml (which is responsible for keeping track of direct dependancies).
#'  (2) The names, unique identifiers, versions and possibly commit numbers of *all* 
#'  	nested dependancies got added to the Manifest.toml. 
#'  
#'  Only Project.toml is necessary for the package to work. The Manifest.toml file 
#'  is only important if you want a snapshot of working versions of all the packages 
#'  used in your package. 
#'  
#'  Generally the workflow works like this:
#'  
#'  
#'  (a) Modify/add some code to `src/Project_Gaussian1.jl` and add some tests 
#'  	to `test/runtests.jl`
#'  
#'  (b) Update the default julia env (press `]` then `pkg> up`)
#'  
#'  (b) Test the code and the updates to the packages via the previous section
#'  
#'  (c) Update the `Manifest.toml` via 
#'

using Pkg 
pkg"activate Project_Gaussian1"
pkg"up"



#' Adding `scr/more_code.jl` and `include("more_code.jl")` to `src/Project_Gaussian1`
#' ===================================================================



#' `instantiate` downloads all the packages declared in that manifest 
#' ===================================================================


#' Suppose someone sends you a `NewProject/` which forms a julia package. 
#' If it has a Manifest.toml file you can do this to mirror the state of 
#' packages on that persons computer

```
shell> cd NewProject/
julia> using Pkg
(@v1.4) pkg> activate .
(NewProject) pkg> instantiate
```





