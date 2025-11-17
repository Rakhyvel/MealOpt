using NLsolve

# Example: 3 ingredients, 3 nutrients
x0 = [100.0, 100.0, 100.0]  # initial guess

# Ingredient × nutrient matrix
A = [
    1.65 0.31 0.0;   # chicken
    1.3  0.025 0.28; # rice
    0.35 0.028 0.05  # broccoli
]

# Target nutrients
b = [2700.0, 160.0, 300.0]

# Residual function
function residual!(F, x)
    F[:] = (A * x .- b) ./ b
end

# Solve
sol = nlsolve(residual!, x0; method = :newton)

println("Optimized ingredient amounts:")
println(sol.zero)