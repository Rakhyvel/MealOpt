using JuMP, Ipopt

# Ingredient x nutrient matrix
nutrients = [
    1.65 0.31 0.0;   # chicken
    1.3  0.025 0.28; # rice
    0.35 0.028 0.05  # broccoli
]

target_nutrients = [2700.0, 160.0, 300.0]

model = Model(Ipopt.Optimizer)
@variable(model, 0 <= decision[1:3] <= 1000) # grams

@objective(model, Min, sum(((nutrients * decision - target_nutrients) ./ target_nutrients).^2))

optimize!(model)

x_opt = value.(decision)
println(x_opt)