#' NLopt
#' ==========================================================

#' NLopt is a high quality optimization package ported to Julia. 
#' I highly recommend it. 
#'
#' Here are the modules we will use in this notebook


using NLopt
using LinearAlgebra
using BenchmarkTools


#'  Anonymous (i.e. un-named or lambda) functions
#' ----------------------------------------------------------
#'
#' Convenient for piping, do syntax, `map` and optimization


x -> sin(x^2) #'

y = [1.9, 2.0] |> x->cos(x[1])  |> x -> x+2 |> log #'

map(x -> cos(x^2), [π/4,π/2,π]) #'

(cos∘exp∘log)(.1) #'

cos(exp(log(.1))) #'

(cos∘exp∘log).(rand(10,10)) #'

y1 = map([π/4,π/2,π]) do x 
    z = cos(x+1) + 2
    log(z)
end #'

y2 = map(x -> (z=cos(x+1)+2 ; log(z)), [π/4,π/2,π]) #'

#' You can also give names to anonymous functions

anon_fun1 = x -> sin(x^2) 
anon_fun1(2.0)

#' Long form of anonymous functions

a = 10
anon_fun2 = function (x,y)
    z = x+y+a 
    z += sin(z)
    return z^2
end

#' This also works 

anon_fun2 = (x,y) -> begin
    z = x+y+a 
    z += sin(z)
    z^2 # but you don't have access to the `return keyword`
end



#' Let blocks for closing global references
#' ----------------------------------------------------------

a = 10
const c = 7

f1 = () -> a + c

f2 = let 
    ()-> a + c
end

f3 = let c=c
    ()-> a + c
end

f4 = let a=a
    ()-> a + c
end

f5 = let a=a, c=c
    ()-> a + c
end

function createf6(a,c)
    return ()-> a + c
end
f6 = createf6(a,c)


#' you can check to see how these functions handles their internal variables 

@show code_info_f1 = code_lowered(f1,Int);
@show code_info_f2 = code_lowered(f2,Int);
@show code_info_f3 = code_lowered(f3,Int);
@show code_info_f4 = code_lowered(f4,Int);
@show code_info_f5 = code_lowered(f5,Int);
@show code_info_f6 = code_lowered(f6,Int);

#' Notice the reference to Main.a or Main.c in f1, ..., f4. 
#' Only f5 and f6 hold `a` and `c` as an internal state and 
#' don't refer to global variables.


#' Lets benchmark these 6 functions  

#' The last 3 are all fast ...
@benchmark f6() #'

@benchmark f5() #'

@benchmark f4() #'


#' ... the first three are slower (x 2) since they reference a non-const global
@benchmark f1() #'

@benchmark f2() #'

@benchmark f3() #'






#' NLopt with closures
#' ----------------------------------------------------------
#' Usually, when optimizing a function you want to include gradient calculations. 
#' However, in the CMB case these are complicated. 
#' In NLopt you can choose from a collection of non-gradient optimization algorithms. 
#' We will use the one called `LN_BOBYQA`.
#'
#' Here is a link some optimization algorithms that do not require gradient 
#' calculations:
#' see http://ab-initio.mit.edu/wiki/index.php/NLopt_Reference for a reference
#' ... also see https://nlopt.readthedocs.io/en/latest/NLopt_Algorithms/
#' 
#' Naming convention for algorithms is 
#' 
#' {G,L}{N,D}_xxxx 
#' 
#' G/L - denotes global/local optimization
#' N/D - denotes derivative-free/gradient-based algorithms

LN_algm = [:LN_BOBYQA, :LN_COBYLA, :LN_PRAXIS, :LN_NELDERMEAD, :LN_SBPLX]
LD_algm = [:LD_MMA, :LD_SLSQP, :LD_LBFGS, :LD_TNEWTON]


#' Lets make functions we want to optimize

Σ = [
        2   -.1
      -.1    2
    ]

μ = [-1, 4]

#'

llmax, llmax_with_grad = let μ=μ, Σ=Σ

    llmax = function (x) 
        xμ    = x .- μ
        Σ⁻¹xμ = Σ \ xμ
        ll = - (xμ ⋅ Σ⁻¹xμ)
        return ll
    end

    llmax_with_grad = function (x, grad) 
        xμ    = x .- μ
        Σ⁻¹xμ = Σ \ xμ
        ll = - (xμ ⋅ Σ⁻¹xμ)
        if length(grad)>0
            grad .= .- 2 .* Σ⁻¹xμ
        end
        return ll
    end

    llmax, llmax_with_grad
end




#' NLopt expects that the function your trying to optimze takes two arguments: 
#' the variable `x` is the one your optimizing over and a variable `grad` which, 
#' when the funtion is called, over-writes `grad` with the gradient of the objective 
#' function at `x`. In this case we don't do anything to `grad` since 
#' we are only using non-gradient based algorithms.
#' 
#' The following code sets up the optimzation object.


#' pick the optimizer and the number of varibles to optimize

opt1 = Opt(:LN_NELDERMEAD, 2) # second arg is the number of variables to optimize
opt2 = Opt(:LD_LBFGS, 2) # second arg is the number of variables to optimize

#' min or max ... specify the objective

opt1.max_objective = (x,grad) -> llmax(x)
opt2.max_objective = llmax_with_grad

# opt1.min_objective = (x,grad) -> - llmax(x)
# opt2.min_objective = (x,grad) -> - llmax(x)

#' other options

opt1.maxtime = 10 # <--- max time in seconds
opt2.maxtime = 10
opt1.lower_bounds = [-10.0, -Inf]
opt2.lower_bounds = [-10.0, -Inf]
opt1.upper_bounds = [10.0, Inf]
opt2.upper_bounds = [10.0, Inf]

#' 

# opt.maxeval
# opt.xtol_rel
# opt.xtol_abs
# opt.ftol_rel
# opt.ftol_abs



#' Note: I set the upper and lower bounds to the bounding box constraints used for training pypico. 
#'
#' Now we tell NLopt to optimize it. 

optf1, optx1, ret1 = optimize(opt1, Float64[0,0])
optf2, optx2, ret2 = optimize(opt2, Float64[0,0])



