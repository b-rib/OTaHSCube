# OTaHSCube - **O**ptimal **T**asks **a**nd **H**eater **S**cheduling Applied to **Cube**Sats


**OTaHSCube** is a [Julia](http://www.julialang.org/) package dedicated to energy and temperature-aware task scheduling for quality-of-service assurance in CubeSats
 
## Dependencies

* Julia
* JuMP
* Gurobi
* JLD

## Usage
### Main file
```julia
jobs = 7 # insert here number of tasks/jobs, excluding the heater task
T = 48 # insert here time horizon / orbit duration

just_plot = false # define if this execution aims only to plot an already obtained result

if !just_plot
    include("params.jl")
    include("examples/$(T)_$(jobs).jl")
    include("fvm_temp_checker.jl")
    include("model.jl")
else
    #import vars here
    include("plot.jl")
```
 
### Parameters file
The **parameters.jl** file is a julia lang file containing the following definitions:

| Variable (Code) 	| Variable (Paper)	| Definition		|
|-------------------|-------------------|-------------------|
| M 				| $M$				| a large number which would not be part of any optimal solution, used in big-M constraints
| q 				| $Q$				| nominal battery capacity (in Ah) 
| soc0		 		| $SoC_1$			| initial battery SoC
| lower_bound		| $\rho$			| minimum accepted battery SoC
| bat_usage 		| $\gamma$			| maximum charge/discharge battery current (in Ampères)
| ef 				| $e$				| battery charge/discharge efficiency
| v_bat 			| $V_b$				| battery voltage

### Example file
The \$(T)\_\$(jobs).jl file is a julia lang file containing the following definitions:

| Variable (Code) 	| Variable (Paper)	| Definition		|
|-------------------|-------------------|-------------------|
| jobs 				| $J$				| number of jobs
| T 				| $T$				| time horizon
| resource_p 		| $r_t$				| vector containing the available resource for each time instant
| min_duration 		| $t_j^{\min}$		| vector containing the minimum duration of each job
| max_duration 		| $t_j^{\max}$		| vector containing the maximum duration of each job
| min_period_job 	| $p_j^{\min}$		| vector containing the minimum period for each job
| max_period_job 	| $p_j^{\max}$		| vector containing the maximum period for each job
| min_statup 		| $y_j^{\min}$		| vector containing the minimum number of startups for each job
| max_statup 		| $y_j^{\max}$		| vector containing the maximum number of startups for each job
| win_min 			| $w_j^{\min}$		| minimum time window for each job
| win_max 			| $w_j^{\max}$		| maximum time window for each job
| priority 			| $u_j$				| vector containing the priority of each job
| use_p 			| $q_j$				| vector containing the power usage of each job


#### Example **48_7** parameters
| $j$			| 1	 	| 2	 	| 3	 	| 4	 	| 5	 	| 6	 	| 7	 	| 8 \(heater\)	|
|---------------|-------|-------|-------|-------|-------|-------|-------|---------------|
| $u_j$			| 7	 	| 2	 	| 4	 	| 3	 	| 5	 	| 1	 	| 6	 	| 0				|
| $q_j$			| 2\.39 | 0\.80 | 0\.76 | 1\.13 | 2\.49 | 0\.76 | 1\.17 | 1\.00		 	|
| $y_j^{\min}$ 	| 1	 	| 1	 	| 1	 	| 2	 	| 2	 	| 2	 	| 1	 	| 2				|
| $y_j^{\max}$ 	| 1	 	| 4	 	| 2	 	| 4	 	| 3	 	| 2	 	| 2	 	| 6				|
| $t_j^{\min}$ 	| 2	 	| 2	 	| 3	 	| 2	 	| 4	 	| 1	 	| 2	 	| 10		   	|
| $t_j^{\max}$ 	| 10	| 3	 	| 12	| 10	| 5	 	| 3	 	| 2	 	| 49		   	|
| $p_j^{\min}$  | 5	 	| 8	 	| 10	| 8	 	| 7	 	| 12	| 11	| 1				|
| $p_j^{\max}$  | 47	| 17	| 27	| 22	| 30	| 43	| 43	| 49		   	|
| $w_j^{\min}$  | 0	 	| 0	 	| 0	 	| 0	 	| 9	 	| 0	 	| 0	 	| 0				|
| $w_j^{\max}$  | 48	| 48	| 48	| 48	| 44	| 48	| 48	| 48		   	|



### Output files
 
Two output files are generated, namely:
 
* \$(T)_\$(jobs)_EN.pdf
	+ Graph of: **Energy balance** (W; primary axis) and **SoC** (%; secondary axis) vs. **time** (min)
* \$(T)_\$(jobs)_SCH_TMP.pdf
	+ Graph of: **jobs/tasks activations** ($x$) vs. **time**


## References
Library inspired by Cezar Augusto Rigo`s task scheduling papers.
 
1. Rigo, C. A.; Seman, L. O.; Camponogara, E.; Morsch Filho, E.; Bezerra; E. A . .  Task scheduling for optimal power management and quality-of-service assurance in CubeSats. ACTA Astronautica, v. 179, p. 550-560, 2021. 
 
2. Rigo, C. A. ; Seman, L. O. ; Camponogara, E. ; Morsch Filho, E. ; Bezerra, E. A. . A nanosatellite task scheduling framework to improve mission value using fuzzy constraints. EXPERT SYSTEMS WITH APPLICATIONS, v. 175, p. 114784, 2021.
 
3. Rigo, C. A. ; Seman, L. O. ; Camponogara, E. ; Morsch Filho, E. ; Bezerra, E. A. ; Munari Junior, P. A. . A branch-and-price algorithm for nanosatellite task scheduling to improve mission quality-of-service. EUROPEAN JOURNAL OF OPERATIONAL RESEARCH, 2022.

## How to cite
#### BibTex
```bibtex
@misc{OTaHSCube,
title = {Optimal tasks and heater scheduling applied to the management of CubeSats battery lifespan},
author = {Brenda Fernandes Ribeiro, Laio Oriel Seman, Cezar Antonio Rigo, Eduardo Camponogara},
url = {https://github.com/b-rib/OTaHSCube}
}
```