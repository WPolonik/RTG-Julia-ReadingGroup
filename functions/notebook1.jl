#%% Functions
#%% ==================================================


#%% Basics of function definition
#%% -------------------------------------------------

#%% quick function definition, 2a gets parsed as 2*a
foo1(a, b) = 1 + 2a + 5b^4

#%% basic function definition
function foo2(x, y)
    w = x + y
    z = sin(2 * w)
    w / z, cos(w) # last line is what gets returned, multiple return values separated by comma, could use return
end

#%% evaluate functions with (arguments...)
a, b = foo2(5.0, 7.0)
c    = foo2(5.0, 7.0)

c[1] == a
c[2] == b


#%% broadcast functions with .(arguments...)
x = rand(2,2)
foo1(x[1], 1.0)
foo1.(x, 1.0)

x
y = rand(1,2)

foo1.(x, y)

#%% optional arguments
function fop(x, base = 10)
    x = x^2
    return base * x
    x # this is ignored
end

fop(1)

fop(1, 2)

#%% named arguments with semicolon
function tot(x, y, z=10; style=0, width=0, color=3) # width must be defined
    x + y + style + width/color + z
end

#%%
tot(1,2)

#%%
tot(1,2, width = 3)

#%%
tot(1, 2; width = 3) # the semicolon in this case is un-necssary

tot(1,2,4; width=3)

#%%
function tot2(x, y=1; style, width=0, color=3) # width must be defined
    x + y + style + width/color
end

#%%

tot2(1,2)
tot2(1)
tot2(1, width = 3, style=1)
tot2(1,2, width = 3)
tot2(1, 2; width = 3) # the semicolon in this case is un-necssary


# splating
args = [4, 5]
fop(args...) # calls fob(args[1], args[2])

# splating  a dic for named arguments
dargs = Dict(:style => 5, :width => 3, :color => 1) # :style is of symbol type
tot(4, 5; dargs...) # now the ; is required
tot(4, 5; style=5, width=3, color=1)

dargs[:style]
dargs[:width]

# variable length arguments
bez(a, b, c...) = println("$c")
bez(2,3, 4, 5, 6)

# variable length argument combines nice with splatting
bez2(c...) = bez(1, 2, c...) # the second c is a spat, the first makes a variable length arg
bez2(4,5,6,7,8)
bez(1,2,4,5,6,7,8)

bez2(sin, cos)
bez2(x->x^2, x->tot2(x))

foo5(x) = sin(x)
foo5(x,y,z,w) = println("$x, $y, $z, $w")

args = rand(2,2)
foo5.(args)


foo5(args...)




#%% Infix functions
#%% ----------------------------------------
#%% Infix means a function f(x,y) can be  called x f y, i.e. +(x,y) == x + y
#%% There is a list of unicode symbols which will get transformed to infix.

⊗(5,2) # not defined yet
5 ⊗ 2 # not defined yet

function ⊗(a,b)
    return a^2 - b^2
end

⊗(5,2)
5 ⊗ 2

#%% Anonymous (i.e. un-named or lambda) functions
#%% ----------------------------------------
#%% These are functions which have not been assigned a name yet.
#%% Convenient for piping, do syntax, `map` and optimization

x -> sin(x^2)

#%%
y = [1.9, 2.0] |> x->cos(x[1])  |> x -> x+2 |> log

#%%
map(x -> cos(x^2), [π/4,π/2,π])

#%%
y2 = map(x -> (z=cos(x+1)+2 ; log(z)), [π/4,π/2,π])



#%%
(cos∘exp∘log)(.1)

#%%
cos(exp(log(.1)))

#%%
(cos∘exp∘log).(rand(10,10))



#%% The do syntax for passing long anon functions
y1 = map([π/4,π/2,π]) do x
    z = cos(x+1) + 2
    log(z)
end



#%% You can also give names to anonymous functions

anon_fun1 = x -> sin(x^2)
anon_fun1(2.0)


#%% Long form of anonymous functions


w = 10
anon_fun2 = function (x,y)
    z = x+y+w
    z += sin(z)
    return z^2
end





#%% Pass by reference
#%% ----------------------------------------
#%% julia is pass by reference so function can mutate it's arguments.
#%% This is nice for memory management
#%% the convention is that these mutating functions have a ! at the end of the name



function foo!(x)
    x[1] = 0
    return nothing # optional
end

#%%

a = [1 0; 0 1]
foo!(a)
a


#%%

function foo!(x)
    x .= zeros(size(x))
    return nothing # optional
end

a = [1 0; 0 1]
foo!(a)
a



#%% Notice, however, that the following code doesn't mutate `x` since
#%% the line `x = zeros(size(x))` rebinds local name `x`.
function foo!(x)
    x = zeros(size(x))
    return nothing # optional
end
a = [1 0; 0 1]
foo!(a)
a
