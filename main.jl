using CSV, DataFrames, JuMP, Ipopt

b = [1800.0, 160.0, 100.0, 100.0]

struct Ingredient
    name::String
    calories::Float64
    protein::Float64
    carbs::Float64
    fat::Float64
end

# Ingredient x nutrient matrix
df = CSV.read("ingredients.csv", DataFrame; comment="#")
ingredients = [
    Ingredient(row.name, row.calories, row.protein, row.carbs, row.fats)
    for row in eachrow(df)
]
num_nutrients = 4
num_ingredients = length(ingredients)

# JuMP needs a matrix, so set one up
A = zeros(Float64, num_nutrients, num_ingredients)
for (j, ingr) in enumerate(ingredients)
    A[1, j] = ingr.calories
    A[2, j] = ingr.protein
    A[3, j] = ingr.carbs
    A[4, j] = ingr.fat
end

# setup the model
model = Model(Ipopt.Optimizer)
set_silent(model)
@variable(model, 0 <= x[1:num_ingredients] <= 2)
ε = 1
@objective(model, Min,
    sum(((A*x - b) ./ b).^2)
    + 0.01 * sum(exp(-10 * x[j]) for j=1:num_ingredients)
)
# optimize
optimize!(model)
x_opt = value.(x)

# print out results
real_x_opt = zeros(Float64, num_nutrients)
for i in 1:num_ingredients
    ingredient_amount = x_opt[i]
        name = ingredients[i].name
        rounded_amount = round(ingredient_amount * 100, digits=1)
        println("$name: $(rounded_amount)g")
end

println(A*x_opt)