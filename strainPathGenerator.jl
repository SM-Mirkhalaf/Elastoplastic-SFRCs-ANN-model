#
# Generates a path in 6D strain space and prints to a tab delimited file.
# Picks n_drift directions and walks n_step steps in those directions with
# added noise. The noise vector is multiplied by the variable noise.
# The directions and noise is sampled from a normal distribution with mean
# 0 and standard deviation 1. The output data file is formatted column wise
# given in the order "time" "e11" "e22" "e33" "2*e12" "2*e23" "2*e13".
#
# noise:    Noise multiplicative factor
# n_step:   Number of random steps per directions
# n_drift:  Number of drift directions
# EPS:      Maximum admissible strain component
# t:        Time variable
# path:     File path including file name and number (will append .txt).
# uni:      If true; sets all but one random strain component to 0.

function strainPathGenerator(noise,n_step,n_drift,EPS,t,path,uni)
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
    # Input format is shearstrain*2, therefore those components are scaled.
    eps[:,4:end] = eps[:,4:end]*2

    header = ["time" "e11" "e22" "e33" "2*e12" "2*e23" "2*e13"]
    currentPath =path*".txt"
    open(currentPath, "w") do io
        writedlm(io, vcat(header,hcat(t,eps)))
    end

    return nothing
end
