#
# Writes *.mat for analysis of linear exponential isotropic hardening matrix
# with elastic fibers. The loading conditions are loaded from a strain path
# file. The loading conditions are general 3D loading, prescribed 6D strain.
#
# inPath:                      The path of the input strain file.
# outPath:                     The path of the output *.mat file.
# finalTime:                   Final time of the analysis.
# maxTimeInc:                  Maximum integration time step.
# minTimeInc:                  Minimum integration time step.
# integrationParameter:        Integration parameter.
# numberAngleIncrements:       Number of angle increments.
# outputPrecision:             Output number of significant figures.
# PlaneConditionInitialGuess:  Is the initial guess plane conditions?
# OTtraceTol:                  Orientation tensor trace tolerance.
# youngFiber:                  Young's modulus of fiber.
# poissonFiber:                Poisson's ratio of fiber.
# fiberVolumefraction:         Volume fraction of fiber.
# fiberAspectratio:            Fiber aspect ratio.
# fiberOrientation:            Fiber orientation.
# youngMatrix:                 Young's modulus of matrix.
# poissonMatrix:               Poisson's ratio of matrix.
# yieldMatrix:                 Yield stress of matrix.
# hardeningModulusMatrix:      Hardening modulus R_inf of matrix.
# hardeningExponentMatrix:     Hardening exponent m of matrix.
# hardeningModulus2Matrix:     Linear hardening modulus of matrix.
# matrixVolumefraction:        Volume fraction of matrix.
# orientationTensor:           2nd order orientation tensor on Voight form.[OPT]
#
function writemat(inPath,outPath,outputName,finalTime,maxTimeInc,minTimeInc,
    integrationParameter,numberAngleIncrements,outputPrecision,
    PlaneConditionInitialGuess,OTtraceTol,youngFiber,poissonFiber,
    fiberVolumefraction,fiberAspectratio,fiberOrientation,
    youngMatrix,poissonMatrix,yieldMatrix,hardeningModulusMatrix,
    hardeningExponentMatrix,hardeningModulus2Matrix,matrixVolumefraction,
    inPath2 = "")

analysisName = outPath[findlast("/",outPath)[1]+1:end-4]

separator = "##########################################"

# Begin by reading strain data file.
strainData = open(inPath, "r") do io
    readdlm(io, '\t')
end
# Read orientation tensor if applicable.
if fiberOrientation == "random_3D"
    a = ["" "" "" "" "" ""]
else
    orientationTensor = open(inPath2, "r") do io
        readdlm(io, '\t')
    end
    a = string.(orientationTensor[2,:])
end

# Define entries for sections of *.mat
fiberMATERIAL = [""; separator; "MATERIAL"; "name = Fiber"; "type = elastic";
"elastic_model = isotropic"; "Young = "*youngFiber; "Poisson = "*poissonFiber;
""]

matrixMATERIAL = [separator; "MATERIAL"; "name = Matrix";
"type = J2_plasticity"; "consistent_tangent = on"; "elastic_model = isotropic";
"Young = "*youngMatrix; "Poisson = "*poissonMatrix;
"yield_stress = "*yieldMatrix; "hardening_model = exponential_linear";
"hardening_modulus = "*hardeningModulusMatrix;
"hardening_exponent = "*hardeningExponentMatrix;
"hardening_modulus2 = "*hardeningModulus2Matrix; "isotropic_method = spectral";
""]

if fiberOrientation == "random_3D"
    fiberPHASE = [separator; "PHASE";"name = InclusionPhase";
    "type = inclusion"; "volume_fraction = "*fiberVolumefraction;
    "behavior = deformable_solid"; "material = Fiber";
    "aspect_ratio = "*fiberAspectratio;
    "orientation = "*fiberOrientation; "coated = no"; ""]
else
    fiberPHASE = [separator; "PHASE";"name = InclusionPhase";
    "type = inclusion"; "volume_fraction = "*a[7];
    "behavior = deformable_solid"; "material = Fiber";
    "aspect_ratio = "*fiberAspectratio;
    "orientation = "*fiberOrientation;
    "orientation_11 = "*a[1]; "orientation_22 = "*a[2];
    "orientation_33 = "*a[3]; "orientation_12 = "*a[4];
    "orientation_13 = "*a[5]; "orientation_23 = "*a[6];
    "closure = orthotropic"; "coated = no"; ""]
end

if fiberOrientation == "random_3D"
    matrixPHASE = [separator; "PHASE";"name = MatrixPhase"; "type = matrix";
    "volume_fraction = "*matrixVolumefraction; "material = Matrix"; ""]
else
    matrixPHASE = [separator; "PHASE";"name = MatrixPhase"; "type = matrix";
    "volume_fraction = "*string(1-parse(Float64,a[7])); "material = Matrix"; ""]
end

MICROSTRUCTURE = [separator; "MICROSTRUCTURE"; "name = TheMicrostructure";
"phase = MatrixPhase"; "phase = InclusionPhase"; ""]

LOADING = [separator; "LOADING"; "name = Mechanical"; "type = strain";
"load = General_3D"; "initial_strain_11 = 0.0e+00"; "strain_11 = 1.0e+00";
"initial_strain_22 = 0.0e+00"; "strain_22 = 1.0e+00";
"initial_strain_33 = 0.0e+00"; "strain_33 = 1.0e+00";
"initial_strain_12 = 0.0e+00"; "strain_12 = 1.0e+00";
"initial_strain_23 = 0.0e+00"; "strain_23 = 1.0e+00";
"initial_strain_13 = 0.0e+00"; "strain_13 = 1.0e+00";
"history = user_defined"; "history_component_11 = e11";
"history_component_11_value = relative";
"history_component_22 = e22"; "history_component_22_value = relative";
"history_component_33 = e33"; "history_component_33_value = relative";
"history_component_12 = e12"; "history_component_12_value = relative";
"history_component_23 = e23"; "history_component_23_value = relative";
"history_component_13 = e13"; "history_component_13_value = relative";
"quasi_static = on"; ""]

RVE = [separator; "RVE"; "type = classical";
"microstructure = TheMicrostructure"; ""]

ANALYSIS = [separator; "ANALYSIS"; "name = "*analysisName; "type = mechanical";
"loading_name = Mechanical";
"final_time = "*finalTime; "max_time_inc = "*maxTimeInc;
"min_time_inc = "*minTimeInc; "finite_strain = off";
"output_name = "*outputName; "load = DIGIMAT"; "homogenization = on";
"homogenization_model = Mori_Tanaka"; "second_order = on";
"integration_parameter = "*integrationParameter;
"number_angle_increments = "*numberAngleIncrements;
"output_precision = "*outputPrecision; "stiffness = off";
"plane_condition_initial_guess = "*PlaneConditionInitialGuess;
"OT_trace_tol = "*OTtraceTol; "hybrid_methodology = off";
"hybrid_failure_criteria = off"; "FPGF_refinement = on"; ""; ""; ""]

OUTPUT = [separator; "OUTPUT"; "name = "*outputName;
"RVE_data = Custom,time,S.11,S.22,S.33,S.12,S.13,S.23";
"Phase_data = InclusionPhase,None"; "Phase_data = MatrixPhase,None";
"Engineering_data = Default"; "Log_data = Default"; "Dependent_data = Default";
"Fatigue_data = Default"; "Composite_data = None"; ""]

point = repeat(["point = "],outer=length(strainData[2:end,1]))

e11FUNCTION = [separator; "FUNCTION"; "name = e11"; "type = piecewise_linear";
point.*string.(strainData[2:end,1]).*",".*string.(strainData[2:end,2]); ""]

e22FUNCTION = [separator; "FUNCTION"; "name = e22"; "type = piecewise_linear";
point.*string.(strainData[2:end,1]).*",".*string.(strainData[2:end,3]); ""]

e33FUNCTION = [separator; "FUNCTION"; "name = e33"; "type = piecewise_linear";
point.*string.(strainData[2:end,1]).*",".*string.(strainData[2:end,4]); ""]

e12FUNCTION = [separator; "FUNCTION"; "name = e12"; "type = piecewise_linear";
point.*string.(strainData[2:end,1]).*",".*string.(strainData[2:end,5]); ""]

e23FUNCTION = [separator; "FUNCTION"; "name = e23"; "type = piecewise_linear";
point.*string.(strainData[2:end,1]).*",".*string.(strainData[2:end,6]); ""]

e13FUNCTION = [separator; "FUNCTION"; "name = e13"; "type = piecewise_linear";
point.*string.(strainData[2:end,1]).*",".*string.(strainData[2:end,7])]

open(outPath, "w") do io
    writedlm(io,fiberMATERIAL)
    writedlm(io,matrixMATERIAL)
    writedlm(io,matrixPHASE)
    writedlm(io,fiberPHASE)
    writedlm(io,MICROSTRUCTURE)
    writedlm(io,LOADING)
    writedlm(io,RVE)
    writedlm(io,ANALYSIS)
    writedlm(io,OUTPUT)
    writedlm(io,e11FUNCTION)
    writedlm(io,e22FUNCTION)
    writedlm(io,e33FUNCTION)
    writedlm(io,e12FUNCTION)
    writedlm(io,e23FUNCTION)
    writedlm(io,e13FUNCTION)
end
end
