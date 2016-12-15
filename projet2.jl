using Gurobi
#Reception of the data
function fr(m)
  demand = readcsv(ARGS[1]) # [i, t]: demand for i in t; this quantity is withdrawn from the stocks.
  transitionCosts = readcsv(ARGS[2]) # [i, j]: cost to go from i to j
  transitionForbiddenMatrix = readcsv(ARGS[3]) # transitions from [:, 1] to [:, 2] are forbidden
  transitionForbiddenListPairs = [(transitionForbiddenMatrix[i, 1], transitionForbiddenMatrix[i, 2]) for i in size(transitionForbiddenMatrix, 1)] # (a, b): forbidden to go from a to b (but not the reverse transition!)
  minTime = readcsv(ARGS[4]) # Number of time steps the given paper must be produced.
  energyConsumption = vec(readcsv(ARGS[5])) # Energy consumption for each type of paper
  electricityPrice = vec(readcsv(ARGS[6]))

  nTypes = length(energyConsumption) # == size(demand, 1) == size(transitionCosts, 1) == size(transitionCosts, 2) == size(transitionForbiddenMatrix, 1) == size(transitionForbiddenMatrix, 2)
  nTimes = size(demand, 2) # <= length(electricityPrice)

  horizon = length(demand[1, :])
  nb_papers = length(demand[:, 1])
  print(horizon);

  @variable(m, producer[1:horizon, 1:nb_papers], Bool)
  @variable(m, transition[1:horizon] >= 0, Int)

  @objective(m, Min, sum{transition[t] + electricityPrice[t] * sum{producer[t, p] * energyConsumption[p], p=1:nb_papers}, t=1:horizon})

  for p in 1 : nb_papers
    @constraint(m, sum{producer[t, p], t=1:horizon} >= sum{demand[t, p], t=1:horizon})
  end

  for t in 1 : horizon
    @constraint(m, sum{producer{t, p}, p=1:nb_papers} <= 1)
  end

  for p in 1 : nb_papers
    for t in 2 : horizon
      for to in 1 : minTime[p]
        @constraint(m, producer[t + to, p] >= producer[t, p] - producer[t-1, p])
      end
    end
  end

  for t in 2 : horizon
    for i in 1 : nb_papers
      for j in 1 : nb_papers
        @constraint(m, transition[t] >= transitionCosts[i, j] * (producer[t-1, i] - producer[t, j] - 1))
      end
    end
  end
end
