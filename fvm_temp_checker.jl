using PyCall
py"""
import sys
import numpy as np
import copy as cp
KELVIN = 273.15

def dataGen(
    heater: bool = True,
    initial_condition: float = 25 + KELVIN
    ):

    boundary_cond = [50+KELVIN, KELVIN, KELVIN, KELVIN, KELVIN, KELVIN]
    x_lenght = 0.02
    x_points = 5
    csv_out = False
    y_lenght = 0.02
    z_lenght = 0.02
    dimension = 3
    y_points = 5
    z_points = 5
    t_points = 10
    t_total = 60.0
    iterations = 50
    conductivity = 2
    rho_c = 1e7

    boundary = np.array(boundary_cond)

    #Step per axis
    x_step = x_lenght / x_points
    y_step = y_lenght / y_points
    z_step = z_lenght / z_points
    t_step = t_total / t_points

    #TDMA equations
    deltaV = x_step * y_step * z_step
    Aw = y_step * z_step
    Ae = y_step * z_step
    An = x_step * z_step
    As = x_step * z_step
    Ab = x_step * y_step
    At = x_step * y_step
    ap0 = rho_c * deltaV / t_step

    #Temperature vector ititialization
    Temp = np.zeros((x_points + 2, y_points + 2, z_points + 2, t_points + 2))

    #Initial condition (t = 0)
    if initial_condition is not None:
        for x_i in range(0,x_points+2):
            for y_i in range(0,y_points+2):
                for z_i in range(0,z_points+2):
                    Temp[x_i, y_i, z_i, 0] = initial_condition

    #Position vectors
    x_position = np.zeros((x_points + 1))
    x_position[(x_points)] = cp.deepcopy(x_lenght) #last point
    for x_i in range(1, (x_points), 1):
        x_position[x_i] = x_step * ((x_i - 1) + .5)

    y_position = np.zeros((y_points + 1))
    y_position[(y_points)] = cp.deepcopy(y_lenght) #last point
    for y_i in range(1, (y_points), 1):
        y_position[y_i] = y_step * ((y_i - 1) + .5)

    z_position = np.zeros((z_points + 1))
    z_position[(z_points)] = cp.deepcopy(z_lenght) #last point
    for z_i in range(1, (z_points), 1):
        z_position[z_i] = z_step * ((z_i - 1) + .5)

    #Time vector
    t_vector = np.zeros((t_points + 1))
    for t_i in range(1, (t_points + 1), 1):
        t_vector[t_i] = t_step * t_i

    #Boundary conditions
    n, s, e, w, t, b = 0, 1, 2, 3, 4, 5
    for t_i in range(0, t_points + 2):
        for x_i in range(0, x_points + 2):
            for y_i in range(0, y_points + 2):
                for z_i in range(0, z_points + 2):
                    if x_i == 0:
                        Temp[x_i , y_i, z_i, t_i] = boundary[0]
                    elif x_i == x_points+1:
                        Temp[x_i , y_i, z_i, t_i] = boundary[1]
                    elif y_i == 0:
                        Temp[x_i , y_i, z_i, t_i] = boundary[2]
                    elif y_i == y_points+1:
                        Temp[x_i , y_i, z_i, t_i] = boundary[3]
                    elif z_i == 0:
                        Temp[x_i , y_i, z_i, t_i] = boundary[4]
                    elif z_i == z_points+1:
                        Temp[x_i , y_i, z_i, t_i] = boundary[5]

    #Nodes calculation (border)
    a_n = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    a_s = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    a_e = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    a_w = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    a_t = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    a_b = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Su_n = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Su_s = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Su_e = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Su_w = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Su_t = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Su_b = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Sp_n = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Sp_s = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Sp_e = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Sp_w = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Sp_t = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Sp_b = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Su = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Sp = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    ap = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])

    alpha = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    beta = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    var_A = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    Cp = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    var_C = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    var_D = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])
    ap = np.zeros([(x_points + 2), (y_points + 2), (z_points + 2), (t_points + 1)])

    #Nodes calculation (middle)
    for t_i in range(1, t_points + 1):
        for ti in range(20):
            for x_i in range(1, x_points + 1):
                for y_i in range(1, y_points  + 1):# * (dimension > 1)):
                    for z_i in range(1, z_points  + 1):# * (dimension > 2)):
                        if x_i == 1:
                            a_e[x_i, y_i, z_i, t_i] = conductivity * Ae / x_step
                            #a_w[x_i, y_i, z_i, t_i] = 0
                            if heater:
                                Su_w[x_i, y_i, z_i, t_i] = 2 * conductivity * Aw * Temp[0, y_i, z_i, t_i] / x_step #!!!!!!
                                Sp_w[x_i, y_i, z_i, t_i] = - (2 * conductivity * Aw) / x_step
                            else:
                                Su_w[x_i, y_i, z_i, t_i] = 0
                                Sp_w[x_i, y_i, z_i, t_i] = 0
                        elif x_i == x_points:
                            #a_e[x_i, y_i, z_i, t_i] =  0
                            Su_e[x_i, y_i, z_i, t_i] = 2 * conductivity * Ae * KELVIN / x_step #!!!!!!
                            Sp_e[x_i, y_i, z_i, t_i] = - (2 * conductivity * Ae) / x_step
                            a_w[x_i, y_i, z_i, t_i] = conductivity * Aw / x_step
                            # Su_e[x_i, y_i, z_i, t_i] = 2 * conductivity * Ae / x_step
                            # Sp_e[x_i, y_i, z_i, t_i] = -2 * conductivity * Ae / x_step
                        else:
                            a_e[x_i, y_i, z_i, t_i] = conductivity * Ae / x_step
                            a_w[x_i, y_i, z_i, t_i] = conductivity * Aw / x_step
                            # Su_e[x_i, y_i, z_i, t_i] = 0
                            # Su_w[x_i, y_i, z_i, t_i] = 0 
                            # Sp_e[x_i, y_i, z_i, t_i] = 0
                            # Sp_w[x_i, y_i, z_i, t_i] = 0

                        if y_i == 1:
                            a_n[x_i, y_i, z_i, t_i] = conductivity * An / y_step
                            #a_s[x_i, y_i, z_i, t_i] = 0
                            # Su_s[x_i, y_i, z_i, t_i] = 2 * conductivity * As * Temp[x_i, y_i, z_i, t_i] / y_step
                            # Sp_s[x_i, y_i, z_i, t_i] = -2 * conductivity * As / y_step
                        elif y_i == y_points:
                            # a_n[x_i, y_i, z_i, t_i] = 0
                            a_s[x_i, y_i, z_i, t_i] = conductivity * As / y_step
                            # Su_n[x_i, y_i, z_i, t_i] = 2 * conductivity * An * Temp[x_i, y_i, z_i, t_i] / y_step
                            # Sp_n[x_i, y_i, z_i, t_i] = -2 * conductivity * An / y_step
                        else:
                            a_n[x_i, y_i, z_i, t_i] = conductivity * An / y_step
                            a_s[x_i, y_i, z_i, t_i] = conductivity * As / y_step
                            # Su_n[x_i, y_i, z_i, t_i] = 0
                            # Su_s[x_i, y_i, z_i, t_i] = 0
                            # Sp_n[x_i, y_i, z_i, t_i] = 0
                            # Sp_s[x_i, y_i, z_i, t_i] = 0

                        if z_i == 1:
                            a_t[x_i, y_i, z_i, t_i] = conductivity * At / z_step
                            # a_b[x_i, y_i, z_i, t_i] = 0
                            # Su_b[x_i, y_i, z_i, t_i] = 2 * conductivity * Ab * Temp[x_i, y_i, z_i, t_i] / z_step
                            # Sp_b[x_i, y_i, z_i, t_i] = -2 * conductivity * Ab / z_step
                        elif z_i == z_points:
                            # a_t[x_i, y_i, z_i, t_i] = 0
                            a_b[x_i, y_i, z_i, t_i] = conductivity * Ab / z_step
                            # Su_t[x_i, y_i, z_i, t_i] = 2 * conductivity * At * Temp[x_i, y_i, z_i, t_i] / z_step
                            # Sp_t[x_i, y_i, z_i, t_i] = -2 * conductivity * At / z_step
                        else:
                            a_t[x_i, y_i, z_i, t_i] = conductivity * At / z_step
                            a_b[x_i, y_i, z_i, t_i] = conductivity * Ab / z_step
                            # Su_t[x_i, y_i, z_i, t_i] = 0
                            # Su_b[x_i, y_i, z_i, t_i] = 0
                            # Sp_t[x_i, y_i, z_i, t_i] = 0
                            # Sp_b[x_i, y_i, z_i, t_i] = 0

                        Su[x_i, y_i, z_i, t_i] = Su_n[x_i, y_i, z_i, t_i] + Su_s[x_i, y_i, z_i, t_i] + Su_e[x_i, y_i, z_i, t_i] + Su_w[x_i, y_i, z_i, t_i] + Su_t[x_i, y_i, z_i, t_i] + Su_b[x_i, y_i, z_i, t_i]
                        Sp[x_i, y_i, z_i, t_i] = Sp_n[x_i, y_i, z_i, t_i] + Sp_s[x_i, y_i, z_i, t_i] + Sp_e[x_i, y_i, z_i, t_i] + Sp_w[x_i, y_i, z_i, t_i] + Sp_t[x_i, y_i, z_i, t_i] + Sp_b[x_i, y_i, z_i, t_i]
                        
                        ap[x_i, y_i, z_i, t_i] = a_n[x_i, y_i, z_i, t_i] + a_s[x_i, y_i, z_i, t_i] + a_e[x_i, y_i, z_i, t_i] + a_w[x_i, y_i, z_i, t_i] + a_t[x_i, y_i, z_i, t_i] + a_b[x_i, y_i, z_i, t_i] + ap0 - Sp[x_i, y_i, z_i, t_i]
                        var_D[x_i, y_i, z_i, t_i] = cp.deepcopy(ap[x_i, y_i, z_i, t_i])

                        beta[x_i, y_i, z_i, t_i] = cp.deepcopy(a_b[x_i, y_i, z_i, t_i])
                        alpha[x_i, y_i, z_i, t_i] = cp.deepcopy(a_t[x_i, y_i, z_i, t_i])
                        
                        var_C[x_i, y_i, z_i, t_i] = a_w[x_i, y_i, z_i, t_i] * Temp[(x_i - 1), y_i, z_i, t_i] + a_e[x_i, y_i, z_i, t_i] * Temp[(x_i + 1), y_i, z_i, t_i] + a_n[x_i, y_i, z_i, t_i] * Temp[x_i, (y_i + 1), z_i, t_i] + a_s[x_i, y_i, z_i, t_i] * Temp[x_i, (y_i - 1), z_i, t_i] + ap0 * Temp[x_i, y_i, z_i, (t_i - 1)] + Su[x_i, y_i, z_i, t_i]
                        var_A[x_i, y_i, z_i, t_i] = alpha[x_i, y_i, z_i, t_i] / (var_D[x_i, y_i, z_i, t_i] - beta[x_i, y_i, z_i, t_i] * var_A[x_i, y_i, (z_i - 1), t_i])
                        Cp[x_i, y_i, z_i, t_i] = (beta[x_i, y_i, z_i, t_i] * Cp[x_i, y_i, (z_i - 1), t_i] + var_C[x_i, y_i, z_i, t_i]) / (var_D[x_i, y_i, z_i, t_i] - beta[x_i, y_i, z_i, t_i] * var_A[x_i, y_i, (z_i - 1), t_i])
                        
                    for z_i in range(z_points, 0, -1):
                        Temp[x_i, y_i, z_i, t_i] = var_A[x_i, y_i, z_i, t_i] * Temp[x_i, y_i, (z_i + 1), t_i] + Cp[x_i, y_i, z_i, t_i]     

    print(Temp[:,3,3,t_points]-KELVIN) # 3 = midpoints
    return (Temp[3,3,3,t_points]-KELVIN)
"""

function temp_check(x)
    println("heater")
    println(x)
    Temperature = zeros(T)
    Temperature[1] = 25
    for t in 1:T-1
        if x[t] == 1
            Temperature[t+1] = py"dataGen"(true, (Temperature[t] + KELVIN))
        else
            Temperature[t+1] = py"dataGen"(false, (Temperature[t] + KELVIN))
        end
    end
    min = count(x -> x < temperature_range[1], Temperature)
    max = count(x -> x > temperature_range[2], Temperature)
    println("Temperature",Temperature)
    diffs = zeros(T)
    diffs = (25 .- Temperature) / 25
    println(diffs)
    println(min + max)
    if min + max > 0
        return false
    else
        return true
    end
end