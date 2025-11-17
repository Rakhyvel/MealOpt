using CSV, DataFrames, JuMP, Ipopt

target_nutrients = [1800.0, 160.0, 100.0, 100.0]

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
num_ingredients = length(ingredients)

# JuMP needs a matrix, so set one up
A = zeros(Float64, 4, num_ingredients)
for (j, ingr) in enumerate(ingredients)
    A[1, j] = ingr.calories
    A[2, j] = ingr.protein
    A[3, j] = ingr.carbs
    A[4, j] = ingr.fat
end

# setup the model
model = Model(Ipopt.Optimizer)
set_silent(model)
@variable(model, 0 <= decision[1:num_ingredients] <= 1000)
@objective(model, Min, sum(((A * decision - target_nutrients) ./ target_nutrients).^2))

# optimize
optimize!(model)
x_opt = value.(decision)

# print out results
for i in 1:num_ingredients
    ingredient_amount = x_opt[i] * 100
    EPSILON = 0.1
    if ingredient_amount > EPSILON
        name = ingredients[i].name
        rounded_amount = round(ingredient_amount, digits=1)
        println("$name: $(rounded_amount)g")
    end
end