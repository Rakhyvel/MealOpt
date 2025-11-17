using CSV, DataFrames, Evolutionary, DataStructures

lower = [1700.0, 160.0, 60.0, 80.0, 25.0, 400, 11, 15]
upper = [1800.0, Inf,   160.0, Inf, Inf, 420, 40, 100]

struct Ingredient
    name::String
    calories::Float64
    protein::Float64
    carbs::Float64
    fat::Float64
    fiber::Float64
    magnesium::Float64
    zinc::Float64
    vitd::Float64
end

# Ingredient x nutrient matrix
df = CSV.read("ingredients.csv", DataFrame; comment="#")
ingredients = [
    Ingredient(row.name, row.calories, row.protein, row.carbs, row.fats, row.fiber, row.Mg, row.Zn, row["Vit D"])
    for row in eachrow(df)
]
num_nutrients = 8
num_ingredients = length(ingredients)

# JuMP needs a matrix, so set one up
A = zeros(Float64, num_nutrients, num_ingredients)
for (j, ingr) in enumerate(ingredients)
    A[1, j] = ingr.calories
    A[2, j] = ingr.protein
    A[3, j] = ingr.carbs
    A[4, j] = ingr.fat
    A[5, j] = ingr.fiber
    A[6, j] = ingr.magnesium
    A[7, j] = ingr.zinc
    A[8, j] = ingr.vitd
end

epsilon = 0.2
function fitness(x)
    real_x = ifelse.(x .>= epsilon, x, 0.0)
    weight = sum(real_x)
    nutrients = A * real_x
    violation = max.(0.0, lower .- nutrients) + max.(0.0, nutrients .- upper)
    return sum(violation .^ 2) + max(0.0, weight - 6.0)
end

counter = DefaultDict{String, Int}(0)
for iter in 1:500
    res = Evolutionary.optimize(
        fitness,
        zeros(Float64, num_ingredients),
        CMAES(),
        Evolutionary.Options(
            iterations=2000,
        )
    )

    x_opt = res.minimizer
    real_x = ifelse.(x_opt .>= epsilon, x_opt, 0.0)

    # print out results
    for i in 1:num_ingredients
        ingredient_amount = real_x[i]
        if ingredient_amount > 0
            name = ingredients[i].name
            rounded_amount = round(ingredient_amount * 100, digits=1)
            counter[name] += 1
            # println("$name ($freq): $(rounded_amount)g")
        end
    end

    for (key, val) in sort(collect(counter), by = x -> -x[2], rev = true)
        println("$key => $val")
    end

    println(A*real_x)
end