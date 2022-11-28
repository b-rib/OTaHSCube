using Plots;
gr();
using Plots.Measures
fnt = Plots.font("Times", 12)

global plo = []

function plot(x_vector, soc_total)
    x = x_vector[task_heater]
    Temperature = zeros(T)
    Temperature[1] = 25

    for t in 1:T-1
        if x[t] == 1
            Temperature[t+1] = py"dataGen"(true, (Temperature[t] + KELVIN))
        else
            Temperature[t+1] = py"dataGen"(false, (Temperature[t] + KELVIN))
        end
    end

    consumot = zeros(T)

    for j in 1:jobs
        if j != task_heater
            consumot = consumot + x_vector[j] * use_p[j]
        end
    end

    heater_consumption = x_vector[task_heater] * use_p[task_heater]

    z = 1
    nT = round(Int, T * 2)

    plot(resource_p, linecolor=:blue, fontfamily=fnt, ytickfont=fnt, seriestype=:steppost, guidefont=fnt, foreground_color_legend=nothing, linewidth=1.5, title="", background_color_legend=nothing, legend=:topleft, ylims=(0, 25), label="Solar panel power", xlims=(1, z * T), xticks=([1, T], ["0", "$nT"]), right_margin=3mm, xtickfontsize=12, ytickfontsize=12, xguidefontsize=12, yguidefontsize=12, titlefontsize=12, legendfontsize=12)
    plot!(consumot, guidefont=fnt, fillrange=[resource_p resource_p], fillalpha=0.3, xlabel="Time [min]", lab="Battery power", c=:wheat1, fontfamily=fnt, ytickfont=fnt, seriestype=:steppost, foreground_color_legend=nothing, background_color_legend=nothing, legend=:topleft, ylims=(0, 25), right_margin=3mm, xlims=(1, z * T), xticks=([1, T], ["0", "$nT"]), linecolor=:snow, ylabel="Power [W]")
    plot!(consumot, seriestype=:steppost, guidefont=fnt, xlims=(1, z * T), xticks=([1, T], ["0", "$nT"]), label="Tasks total consumption", foreground_color_legend=nothing, background_color_legend=nothing, linecolor=:orange, legend=:topleft, ylims=(0, 25), right_margin=15mm)
    plot!(heater_consumption, seriestype=:steppost, linecolor=:red, fontfamily=fnt, ytickfont=fnt, guidefont=fnt, foreground_color_legend=nothing, linewidth=1.5, title="", background_color_legend=nothing, legend=:topleft, ylims=(0, 25), label="Heater consumption", xlims=(1, z * T), xticks=([1, T], ["0", "$nT"]), right_margin=3mm, xtickfontsize=12, ytickfontsize=12, xguidefontsize=12, yguidefontsize=12, titlefontsize=12, legendfontsize=12)
    display(plot!(twinx(), soc_total * 100, fontfamily=fnt, ytickfont=fnt, guidefont=fnt, color=:green4, label="Soc", xlims=(1, z * T), xticks=([1, T], ["0", "$nT"]), yticks=(40:20:100), legend=:topright, foreground_color_legend=nothing, background_color_legend=nothing, linewidth=1.5, linecolor=:green4, ylabel="SoC [%]", ylims=(20, 100), right_margin=3mm, xtickfontsize=12, ytickfontsize=12, xguidefontsize=12, yguidefontsize=12, titlefontsize=12, legendfontsize=12))

    savefig("results/$(T)_$(jobs)_EN.pdf")

    global plo
    global xtick_label = []

    for i in 0:1:jobs*2-1
        if iseven(i) || i == 0
            push!(xtick_label, "off")
        else
            push!(xtick_label, "on")
        end
    end

    push!(plo, plot(Temperature, linecolor=:magenta, fontfamily=fnt, ytickfont=fnt, guidefont=fnt, foreground_color_legend=nothing, linewidth=1.5, title="", background_color_legend=nothing, legend=:bottomright, ylims=(0, 35), label="Battery temperature", ylabel="Temp [°C]", xlabel="Time [min]", xlims=(1, z * T), xticks=([1, T], ["0", "$nT"]), right_margin=5mm, xtickfontsize=12, ytickfontsize=12, xguidefontsize=12, yguidefontsize=12, titlefontsize=12, legendfontsize=12))

    for j in 1:jobs
        if j == 1
            global plo
            push!(plo, plot(x_vector[j] .+ jobs * 2 .- 2, ylims=(0, jobs * 2), guidefont=fnt, title="", xtickfont=fnt, linewidth=1.5, fontfamily=fnt, ytickfont=fnt, yticks=([0], [""]), seriestype=:steppost, foreground_color_legend=nothing, background_color_legend=nothing, label="$j", xlims=(0, z * T + 1), xticks=([1, T], ["0", "$nT"]), right_margin=5mm, legend=:outerbottomright, xlabel="Time [min]", ylabel="On/Off", yaxis=false, xtickfontsize=12, ytickfontsize=12, xguidefontsize=12, yguidefontsize=12, titlefontsize=12, legendfontsize=12))
        else
            if j == jobs
                display(plot!(x_vector[j] .+ 0.0, ylims=(0, jobs * 2), guidefont=fnt, xtickfont=fnt, linewidth=1.5, fontfamily=fnt, ytickfont=fnt, seriestype=:steppost, label="$j", xlims=(0, z * T + 1), xticks=([1, T], ["0", "$nT"]), yticks=([0], [""]), xtickfontsize=12, ytickfontsize=10, xguidefontsize=12, right_margin=5mm, yguidefontsize=12, titlefontsize=12, legendfontsize=12))
            else
                plot!(x_vector[j] .+ jobs * 2 .- 2 * j, ylims=(0, jobs * 2), guidefont=fnt, xtickfont=fnt, linewidth=1.5, fontfamily=fnt, ytickfont=fnt, seriestype=:steppost, label="$j", xlims=(0, z * T + 1), xticks=([1, T], ["0", "$nT"]), xtickfontsize=12, ytickfontsize=12, xguidefontsize=12, yguidefontsize=12, titlefontsize=12, legendfontsize=12)

            end
        end
    end

    display(plot((plo[i] for i in 1:2)..., layout=(2, 1)))
    savefig("results/$(T)_$(jobs)_SCH_TMP.pdf")
end
