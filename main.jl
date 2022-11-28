using JuMP, Gurobi, PyCall

jobs = 7
T = 48

just_plot = false

if !just_plot
    include("params.jl")
    include("examples/$(T)_$(jobs).jl")
    include("fvm_temp_checker.jl")
    include("model.jl")
else
    #import vars here
    include("plot.jl")