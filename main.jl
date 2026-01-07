using CSV, DataFrames, Evolutionary, DataStructures

shake = [160,     30.0,   4.0,  3.0,  1.0]
soup =  [227,     27.0,   7.0, 10.0,  2.0]
bread = [165,      6.0,  34.0,  0.0,  2.0]
lower = [1600.0, 190.0,   0.0, 80.0, 25.0] - 4.0 * shake - 2.0 * bread
upper = [1800.0,   Inf, 100.0,  Inf,  Inf] - 4.0 * shake - 2.0 * bread

println(lower)
println(upper)

struct Ingredient
    name::String
    calories::Float64
    protein::Float64
    carbs::Float64
    fat::Float64
    fiber::Float64
end

# Ingredient x nutrient matrix
df = CSV.read("ingredients.csv", DataFrame; comment="#")
ingredients = [
    Ingredient(row.name, row.calories, row.protein, row.carbs, row.fats, row.fiber)
    for row in eachrow(df)
]
num_nutrients = 5
num_ingredients = length(ingredients)

# JuMP needs a matrix, so set one up
A = zeros(Float64, num_nutrients, num_ingredients)
for (j, ingr) in enumerate(ingredients)
    A[1, j] = ingr.calories
    A[2, j] = ingr.protein
    A[3, j] = ingr.carbs
    A[4, j] = ingr.fat
    A[5, j] = ingr.fiber
end

epsilon = 0.2
ingredient_lower = fill(0.2, num_ingredients)
ingredient_lower[findfirst(df[:, 1] .== "chicken breast")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "80/20 ground beef")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "90/10 ground beef")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "breakfast sausage")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "shrimp")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "blue crab")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "raw haddock")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "raw cod")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "raw tilapia")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "raw pollock")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "raw sockeye salmon")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "raw ground pork")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "raw top sirloin steak")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "raw pork tenderloin")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "raw pork loin")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "eggs")] = 0.5
ingredient_lower[findfirst(df[:, 1] .== "2% cottage cheese")] = 1.5
ingredient_lower[findfirst(df[:, 1] .== "nonfat greek yogurt")] = 1.5
ingredient_lower[findfirst(df[:, 1] .== "premier protien")] = 3.25
ingredient_lower[findfirst(df[:, 1] .== "kale")] = 0.5
ingredient_lower[findfirst(df[:, 1] .== "arugula")] = 0.5
ingredient_lower[findfirst(df[:, 1] .== "broccoli")] = 0.5
ingredient_lower[findfirst(df[:, 1] .== "portabella mushrooms")] = 0.75
ingredient_lower[findfirst(df[:, 1] .== "raw green cabbage")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "brussels sprouts")] = 0.75
ingredient_lower[findfirst(df[:, 1] .== "celery")] = 0.5
ingredient_lower[findfirst(df[:, 1] .== "gold potato")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "vegetable stock")] = 0.5
ingredient_lower[findfirst(df[:, 1] .== "nectarines")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "pineapple")] = 0.7
ingredient_lower[findfirst(df[:, 1] .== "oranges")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "mandarin")] = 0.45
ingredient_lower[findfirst(df[:, 1] .== "cherries")] = 0.45
ingredient_lower[findfirst(df[:, 1] .== "kiwi")] = 0.45
ingredient_lower[findfirst(df[:, 1] .== "peaches")] = 0.45
ingredient_lower[findfirst(df[:, 1] .== "granny smith apples")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "plum")] = 0.6
ingredient_lower[findfirst(df[:, 1] .== "peaches")] = 1.2
ingredient_lower[findfirst(df[:, 1] .== "green grapes")] = 0.8
ingredient_lower[findfirst(df[:, 1] .== "vita coco")] = 3.25
ingredient_lower[findfirst(df[:, 1] .== "bone broth")] = 2.36
ingredient_lower[findfirst(df[:, 1] .== "black beans")] = 1.3
ingredient_lower[findfirst(df[:, 1] .== "russett potato")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "sweet potato")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "red potato")] = 1.0
ingredient_lower[findfirst(df[:, 1] .== "carb balance tortilla")] = 0.71

ingredient_upper = fill(Inf, num_ingredients)
ingredient_upper[findfirst(df[:, 1] .== "swiss cheese")] = 0.84
ingredient_upper[findfirst(df[:, 1] .== "premier protien")] = 0.0
ingredient_upper[findfirst(df[:, 1] .== "peanut butter")] = 0.4
ingredient_upper[findfirst(df[:, 1] .== "bacon")] = 0.3
ingredient_upper[findfirst(df[:, 1] .== "almonds")] = 0.3
ingredient_upper[findfirst(df[:, 1] .== "walnuts")] = 0.3
ingredient_upper[findfirst(df[:, 1] .== "zucchini")] = 2.0
ingredient_upper[findfirst(df[:, 1] .== "carrots")] = 2.0
ingredient_upper[findfirst(df[:, 1] .== "celery")] = 2.0
ingredient_upper[findfirst(df[:, 1] .== "portabella mushrooms")] = 1.5
ingredient_upper[findfirst(df[:, 1] .== "broccoli")] = 1.5
ingredient_upper[findfirst(df[:, 1] .== "kale")] = 1.5
ingredient_upper[findfirst(df[:, 1] .== "spinach")] = 1.5
ingredient_upper[findfirst(df[:, 1] .== "brussels sprouts")] = 1.5
ingredient_upper[findfirst(df[:, 1] .== "cucumber")] = 1.5
ingredient_upper[findfirst(df[:, 1] .== "onion")] = 1.5
ingredient_upper[findfirst(df[:, 1] .== "pears")] = 1.2
ingredient_upper[findfirst(df[:, 1] .== "pineapple")] = 1.2
ingredient_upper[findfirst(df[:, 1] .== "vita coco")] = 6.5
ingredient_upper[findfirst(df[:, 1] .== "eggs")] = 1.0
ingredient_upper[findfirst(df[:, 1] .== "90/10 ground beef")] = 1.5
ingredient_upper[findfirst(df[:, 1] .== "cherries")] = 1.2
ingredient_upper[findfirst(df[:, 1] .== "plum")] = 1.2
ingredient_upper[findfirst(df[:, 1] .== "granny smith apples")] = 2.0
ingredient_upper[findfirst(df[:, 1] .== "hummus")] = 0.5
ingredient_upper[findfirst(df[:, 1] .== "sour cream")] = 0.3
ingredient_upper[findfirst(df[:, 1] .== "nonfat greek yogurt")] = 1.5
ingredient_upper[findfirst(df[:, 1] .== "2% cottage cheese")] = 1.0
ingredient_upper[findfirst(df[:, 1] .== "breakfast sausage")] = 0.5
ingredient_upper[findfirst(df[:, 1] .== "avocado")] = 1.25

function fitness(x)
    presence = x .>= ingredient_lower
    real_x = presence .* x
    count = sum(presence)

    nutrients = A * real_x
    violation = max.(0.0, lower .- nutrients) + max.(0.0, nutrients .- upper)

    return sum(violation .^ 2)
        + 70000.0 * max(0.0, count)
        + 1000.0 * sum(max.(0.0, real_x .- ingredient_upper) .^ 2)
        + 1000.0 * sum(max.(0.0, ingredient_lower .- real_x) .^ 2)
end

res = Evolutionary.optimize(
    fitness,
    zeros(Float64, num_ingredients),
    CMAES(),
    Evolutionary.Options(
        iterations=2000,
    )
)

x_opt = res.minimizer
presence = x_opt .>= ingredient_lower
real_x = presence .* x_opt

# print out results
for i in 1:num_ingredients
    ingredient_amount = real_x[i]
    if ingredient_amount > 0
        name = ingredients[i].name
        rounded_amount = round(ingredient_amount * 100, digits=1)
        println("$name: $(rounded_amount)g")
    end
end

println(A*real_x)