using JuMP, Gurobi, PyCall, Distributed

jobs = 7
T = 48
just_plot = false

if !(just_plot)
    @everywhere include("params.jl")
    @everywhere include("examples/$(T)_$(jobs).jl")
    @everywhere include("fvm_temp_checker.jl")
    @everywhere include("model.jl")
else
    # global x_vector = load("results/vars/$(T)_$(jobs).jld", "x_vector")
    # global soc_total = load("results/vars/$(T)_$(jobs).jld", "soc_total")
    # @everywhere include("plot.jl")
end