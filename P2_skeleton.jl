# From a command line (i.e. not from Julia!), run this script as: 
#     julia P2_skeleton.jl P2_demand.csv P2_transition_cost.csv P2_transition_forbidden.csv P2_minimum_time.csv P2_energy_consumption.csv P2_electricity_prices.csv

demand = readcsv(ARGS[1]) # [i, t]: demand for i in t; this quantity is withdrawn from the stocks. 
transitionCosts = readcsv(ARGS[2]) # [i, j]: cost to go from i to j
transitionForbiddenMatrix = readcsv(ARGS[3]) # transitions from [:, 1] to [:, 2] are forbidden
transitionForbiddenListPairs = [(transitionForbiddenMatrix[i, 1], transitionForbiddenMatrix[i, 2]) for i in size(transitionForbiddenMatrix, 1)] # (a, b): forbidden to go from a to b (but not the reverse transition!)
minTime = readcsv(ARGS[4]) # Number of time steps the given paper must be produced. 
energyConsumption = vec(readcsv(ARGS[5])) # Energy consumption for each type of paper
electricityPrice = vec(readcsv(ARGS[6]))

nTypes = length(energyConsumption) # == size(demand, 1) == size(transitionCosts, 1) == size(transitionCosts, 2) == size(transitionForbiddenMatrix, 1) == size(transitionForbiddenMatrix, 2)
nTimes = size(demand, 2) # <= length(electricityPrice)

# Do something. 