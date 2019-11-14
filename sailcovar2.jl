using JuMP, Clp, Printf

d = [40 60 75 25]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:4] <= 40)       # boats produced with regular labor
@variable(m, y[1:4] >= 0)             # boats produced with overtime labor
@variable(m, h[1:5] >= 0)             # boats held in inventory
@variable(m, cpos[1:4] >= 0)          #Increase in production
@variable(m, cneg[1:4] >= 0)          #Decrease in production

@constraint(m, h[1] == 10)          # boats held in inventory on before from Q1
@constraint(m, h[5] >= 10)          # boats held in inventory on after from Q4

@constraint(m, flow[i in 1:4], h[i]+x[i]+y[i]==d[i]+h[i+1])     # conservation of boats

@constraint(m, x[1]+y[1]-50 == cpos[1] - cneg[1]  )  # constraint of production Q1
@constraint(m, flow2[i in 2:4], ( x[i]+y[i]  )- ( x[i-1]+y[i-1]  ) == cpos[i] - cneg[i]  ) # constraint of production Q2 Q3 Q4

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(h) + 400*sum(cpos) + 500*sum(cneg) )         # minimize costs

optimize!(m)
@printf("Variation 2: Production-smoothing costs \n")
@printf("Boats to build regular labor: %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]))
@printf("Inventories: %d %d %d %d %d\n ", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))
@printf("Increase production: %d %d %d %d\n", value(cpos[1]), value(cpos[2]), value(cpos[3]), value(cpos[4]))
@printf("Decrease production: %d %d %d %d\n", value(cneg[1]), value(cneg[2]), value(cneg[3]), value(cneg[4]))
@printf("Objective cost: %f\n", objective_value(m))
