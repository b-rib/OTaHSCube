task_heater = jobs + 1

soc0 = 0.7      # [%] de carga (0-1)
q = 5           # [Ampere-hour] bettery cherging capacity
v_bat = 3.6     # [V] nominal battery voltage
bat_usage = 5   # [A] Battery capacity
lower_bound = 0 # [%] Battery lower bound
ef = 0.9        # [%] Battery charging/discharging efficiency 

KELVIN = 273.15
temperature_range = [15 35] # [ºC]
range_mean = (temperature_range[1]+temperature_range[2])/2