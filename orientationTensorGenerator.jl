#
# Generates the second order orientation tensor from a random uniform
# distribution. Will also randomly sample the base volume fraction + 0-50%.
#
# fullyAligned:     Special case to ensure representation of fully aligned.
# fibervf:          Base volume fraction of fiber in the composite material.
# path:             File path including file name and number (will append .txt).
#
function orientationTensorGenerator(fullyAligned,fibervf,path)
    # Generate a random diagonal matrix with trace 1 where components
    # uniformly randomly sampled. See Non-uniform random variate generation by
    # Devroye page 568 for details.
    if fullyAligned
        x = [0;0;0]
        index = rand([1 2 3])
        x[index] = 1
        L = diagm(x)
    else
        x = diff(sort([0;rand(2);1]))
        L = diagm(x)
    end
    # Random sampling of rotation parameters.
    theta = 2*pi*rand()
    phi = 2*pi*rand()
    z = rand()

    # Generate rotation matrix around z-axis.
    R = [cos(theta) sin(theta) 0;
    -sin(theta) cos(theta) 0;
    0 0 1]

    # Generate mirrored householder matrix.
    v = [cos(phi)*sqrt(z); sin(phi)*sqrt(z); sqrt(1-z)]
    P = 2*v*v' - Matrix(I,3,3)

    # Total rotation matrix which is sampled uniformly from SO(3)
    M = P*R
    # Uniformly random sampled orientation tensor.
    a = M*L*M'

    # Randomly sample a volume fraction between initial volume fraction + 0-50%
    vf = string(parse(Float64,fibervf) + parse(Float64,fibervf)*0.5*rand())
    # Write to file!
    header = ["a11" "a22" "a33" "a12" "a13" "a23" "vf"]
    currentPath =path*".txt"
    open(currentPath, "w") do io
        writedlm(io,vcat(header,hcat(a[1,1],a[2,2],a[3,3],a[1,2],a[1,3],a[2,3],
        vf)))
    end
    return nothing
end
