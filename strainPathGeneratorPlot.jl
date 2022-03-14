using Distributions, Random, DelimitedFiles, Plots

noise = 0.5 # Noise multiplicative factor
n_step = 10 # Number of random steps per directions
n_drift = 1 # Number of drift directions
EPS = 0.01 # Maximum admissible strain
n_files = 1 # Number of generated files
t = LinRange(0,1,n_step*n_drift+1) # Time variable
uni = false
plot()

for i = 1:n_files
    X = repeat(rand(Normal(0,1),(n_drift,6)),inner=[n_step, 1])
    X = X./sqrt.(sum((X).^2,dims=2))

    Y = rand(Normal(0,1),(n_drift*n_step,6))
    Y = noise.*Y./sqrt.(sum((Y).^2,dims=2))

    Eps = vcat(zeros(1,6),cumsum(X+Y,dims=1))

    # For unidirectional strain, delete all components except for one.
    if uni
        zeroIndex = [1;2;3;4;5;6]
        deleteat!(zeroIndex,rand(1:6))
        Eps[:,zeroIndex] .= 0
    end

    s = maximum(abs.(Eps))
    eps = Eps.*EPS./s
    plot!(t,eps)
end

current()
