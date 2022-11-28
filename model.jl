println("T = ", T, "; J = ", jobs)

subs = 1
cuts_0 = []
cuts_1 = []
diffs = []
let diffs = diffs
    for iter in 1:50
        if iter == 1
            diffs = zeros(T)
        end

        # Model description
        model = direct_model(Gurobi.Optimizer())
        grb_model = (JuMP.backend(model))
        @variable(model, x[1:subs, 1:jobs, 1:T], binary = true)
        @variable(model, phi[1:subs, 1:jobs, 1:T], binary = true)
        @variable(model, soc[1:T])
        @variable(model, 0 <= alpha[1:T] <= 1)
        @variable(model, b[1:T])
        @variable(model, i[1:T])

        if iter > 1
            for cut in 1:length(cuts_0)
                @constraint(model, sum(x[1, task_heater, pos] for pos in cuts_0[cut]) + sum((1 - x[1, task_heater, pos]) for pos in cuts_1[cut]) >= 1)
            end
        end
        for t in 1:T
            @constraint(model, b[t] / v_bat == i[t])  # P = V * I 
            @constraint(model, b[t] == resource_p[t] - sum(use_p[job] * x[1, job, t] for job in 1:jobs)) # Pin(t) - Putilizado(t) = Pcarga da bateria(t)
            if t == 1
                @constraint(model, soc[t] == soc_inicial + (ef / q) * (i[t] / 60)) # SoC(1) = SoC(0) + p_carga[1]/60
            else
                @constraint(model, soc[t] == soc[t-1] + (ef / q) * (i[t] / 60)) # SoC(t) = SoC(t-1) + (ef / Q) * I(t)
            end
            @constraint(model, lower_bound <= (soc[t]))
            @constraint(model, (soc[t]) <= 1)
        end

        # used resources <= available resources
        for t in 1:T
            @constraint(model, sum(use_p[job] * x[1, job, t] for job in 1:jobs) <= resource_p[t] + bat_usage * v_bat * (1 - alpha[t]))
        end

        # objective
        @objective(model, Max, sum(priority[job] * x[1, job, t] for job in 1:jobs for t in 1:T))# + sum(diffs[t] * x[1,10,t] for t in T))

        # phi define startups de jobs
        for t in 1:T
            for job in 1:jobs
                if t == 1
                    @constraint(model, phi[1, job, t] >= x[1, job, t] - 0)
                else
                    @constraint(model, phi[1, job, t] >= x[1, job, t] - x[1, job, t-1])
                end
            end
        end
        for t in 1:T
            for job in 1:jobs
                @constraint(model, phi[1, job, t] <= x[1, job, t])
            end
        end
        for t in 1:T
            for job in 1:jobs
                if t == 1
                    @constraint(model, phi[1, job, t] <= 2 - x[1, job, t] - 0)
                else
                    @constraint(model, phi[1, job, t] <= 2 - x[1, job, t] - x[1, job, t-1])
                end
            end
        end

        # min/max startups of a job
        for job in 1:jobs
            @constraint(model, sum(phi[1, job, t] for t in 1:T) >= min_statup[job])
            @constraint(model, sum(phi[1, job, t] for t in 1:T) <= max_statup[job])
        end

        # execution window
        for job in 1:jobs
            @constraint(model, sum(x[1, job, t] for t in 1:win_min[job]) == 0)
            @constraint(model, sum(x[1, job, t] for t in win_max[job]+1:T) == 0)
        end

        # min/max period between jobs
        for job in 1:jobs
            for t in 1:T-min_period_job[job]+1
                @constraint(model, sum(phi[1, job, t_] for t_ in t:t+min_period_job[job]-1) <= 1)
            end
        end
        for job in 1:jobs
            for t in 1:T-max_period_job[job]+1
                @constraint(model, sum(phi[1, job, t_] for t_ in t:t+max_period_job[job]-1) >= 1)
            end
        end

        # min/max duration of jobs
        for job in 1:jobs
            for t in 1:T-min_duration[job]+1
                @constraint(model, sum(x[1, job, t_] for t_ in t:t+min_duration[job]-1) >= min_duration[job] * phi[1, job, t])
            end
        end
        for job in 1:jobs
            # max_duration of jobs
            for t in 1:T-max_duration[job]
                @constraint(model, sum(x[1, job, t_] for t_ in t:t+max_duration[job]) <= max_duration[job])
            end
            # min_duration (at end of orbit)
            for t in T-min_duration[job]+2:T
                @constraint(model, sum(x[1, job, t_] for t_ in t:T) >= (T - t + 1) * phi[1, job, t])
            end
        end

        @time begin
            JuMP.optimize!.(model)
        end

        objetivo = JuMP.objective_value.(model)
        println("The Objective Value is: ", objetivo)
        println("Solving time (min): ", solve_time(model) / 60)
        println("T = ", T, "; J = ", jobs)

        println("Start temperature check...")
        checked, diffs = temp_check(JuMP.value.(x[1, task_heater, :]))

        _, position_0 = (JuMP.value.(x[1, task_heater, :]), findall(JuMP.value.(x[1, task_heater, :]) .== 0))
        _, position_1 = (JuMP.value.(x[1, task_heater, :]), findall(JuMP.value.(x[1, task_heater, :]) .== 1))

        push!(cuts_0, position_0)
        push!(cuts_1, position_1)

        if checked == true
            x_vector = [Vector{Any}(undef, 1) for _ in 1:jobs]
            for j in 1:jobs
                x_vector[j] = round.(Int, JuMP.value.(x[1, j, :]))
            end
            soc_total = []

            for t in 1:T
                push!(soc_total, JuMP.value(soc[t]))
            end
            save("results/vars/$(T)_$(jobs).jld", "x_vector", x_vector, "soc_total", soc_total)
            break
        end
    end
end