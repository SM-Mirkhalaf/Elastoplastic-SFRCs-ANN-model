using Distributions, Random, DelimitedFiles, Shell, LinearAlgebra
include("C:/Users/Johan/Documents/Julia/strainPathGenerator.jl")
include("C:/Users/Johan/Documents/Julia/writemat.jl")
include("C:/Users/Johan/Documents/Julia/stressPostprocess.jl")
include("C:/Users/Johan/Documents/Julia/orientationTensorGenerator.jl")

##----Parameters----############################################################
# Number of files is n_end - n_start
n_start = 1 # Start number
n_end = 10 # End number
# Ensure that counter is increasing!
if n_start > n_end
    n_start = 1
    n_end = 10
end


timeSteps = 2000;
# Number of time steps in strain paths must be divisible by 1000!
if timeSteps%1000 != 0
    timeSteps = 1000
end

t = LinRange(0,1,timeSteps+1) # Time variable

strainPath = "C:/Users/Johan/Documents/Julia/StrainData/"
strainNameFormat = "strainData_"
stressPath = "C:/Users/Johan/Documents/Julia/StrainData/"
stressNameFormat = "stressData_"
orientationPath = "C:/Users/Johan/Documents/Julia/StrainData/"
orientationNameFormat = "orientationData_"

matPath = "C:/Users/Johan/Documents/Julia/StrainData/"
matNameFormat = "analysis_"
outputNameFormat = "output_"

finalTime = "1.0e+00"
maxTimeInc = "1.0e-01"
minTimeInc = "1.0e-02"
integrationParameter = "5.0e-01"
numberAngleIncrements = "12"
outputPrecision = "5"

PlaneConditionInitialGuess = "off"
OTtraceTol = "1.0e-01"

youngFiber = "76e+09"
poissonFiber = "2.2e-01"
fiberVolumefraction = "1e-01" # This value if random_3D orientation.
fiberAspectratio = "2.4e+01"
fiberOrientation = "tensor" # "tensor" or "random_3D"

youngMatrix = "3.1e+09"
poissonMatrix = "3.5e-01"
yieldMatrix = "2.5e+07"
hardeningModulusMatrix = "2e+07"
hardeningExponentMatrix = "3.25e+02"
hardeningModulus2Matrix = "1.5e+08"
matrixVolumefraction = "9.0e-01" # This value if random_3D orientation.
                                 # Must be equal to 1-fiberVolumefraction!
################################################################################

# IMPORTANT! Match significant digits of time vector to outputPrecision!
t = round.(t,sigdigits=parse(Int,outputPrecision))

# Generate strain path data. Optionally also generates orientation tensors.
for i = n_start:n_end
    noise = rand()
    n_drift = rand([1 2 5 10 20 25 50 100 200])
    # Calculate n_step by dividing timeStep by n_drift to ensure
    # constant length of time series
    n_step = div(timeSteps,n_drift) # div(x,y) to ensure int.
    EPS = 0.01 + rand()*0.04 # Maximum admissible component in 0.01 to 0.05
    if rand() > 0.9
        uni = true
    else
        uni = false
    end
    strainPathGenerator(noise,n_step,n_drift,EPS,t,
    strainPath*strainNameFormat*string(i),uni)
    if fiberOrientation != "random_3D"
        if rand() > 0.9
            fullyAligned = true
        else
            fullyAligned = false
        end
        orientationTensorGenerator(fullyAligned, fiberVolumefraction,
        orientationPath*orientationNameFormat*string(i))
    end
end

# Write *.mat files for every strain path.
for i = n_start:n_end
    local inPath = strainPath*strainNameFormat*string(i)*".txt"
    local outPath = matPath*matNameFormat*string(i)*".mat"
    outputName = outputNameFormat*string(i)
    if fiberOrientation == "random_3D"
        writemat(inPath,outPath,outputName,finalTime,maxTimeInc,minTimeInc,
        integrationParameter,numberAngleIncrements,outputPrecision,
        PlaneConditionInitialGuess,OTtraceTol,youngFiber,poissonFiber,
        fiberVolumefraction,fiberAspectratio,fiberOrientation,
        youngMatrix,poissonMatrix,yieldMatrix,hardeningModulusMatrix,
        hardeningExponentMatrix,hardeningModulus2Matrix,matrixVolumefraction)
    else
        local inPath2 = orientationPath*orientationNameFormat*string(i)*".txt"
        writemat(inPath,outPath,outputName,finalTime,maxTimeInc,minTimeInc,
        integrationParameter,numberAngleIncrements,outputPrecision,
        PlaneConditionInitialGuess,OTtraceTol,youngFiber,poissonFiber,
        fiberVolumefraction,fiberAspectratio,fiberOrientation,
        youngMatrix,poissonMatrix,yieldMatrix,hardeningModulusMatrix,
        hardeningExponentMatrix,hardeningModulus2Matrix,matrixVolumefraction,
        inPath2)
    end
end

# Run DIGIMAT simulation for every *.mat file.
for i = n_start:n_end
    digimatPath = "C:/MSC.Software/Digimat/2020.0/DigimatMF/exec/"
    digimatInput = "input="*matPath*matNameFormat*string(i)*".mat"

    Shell.run(digimatPath*"DigimatMFPlugin.bat"*" "*digimatInput)

    # Delete unnecessary files to save space!
    rm(strainPath*"analysis_"*string(i)*".log")
    rm(strainPath*"analysis_"*string(i)*".eng")
end

# Postprocess DIGIMAT output to match the generated strain data.
for i = n_start:n_end
    local inPath = matPath*matNameFormat*string(i)*".mac"
    local outPath = stressPath*stressNameFormat*string(i)*".txt"
    stressPostprocess(inPath,outPath,t)

    # Remove *.mac and *.mat files to save space!
    rm(matPath*matNameFormat*string(i)*".mac")
    rm(matPath*matNameFormat*string(i)*".mat")
end
