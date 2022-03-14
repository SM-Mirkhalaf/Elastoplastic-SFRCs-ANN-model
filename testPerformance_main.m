% LOAD NET
load('gru500Net.mat')
% LOAD CURRENT TEST
load('sample_2_uni1_strain.mat')
load('sample_2_uni1_stress.mat')

%% SET PARAMETERS
a_11 = 0.649;
a_22 = 0.139;
a_33 = 0.212;
a_12 = 0.011;
a_13 = -0.117;
a_23 = -0.154;

v = 0.131;

% PUT PLOT TITLES HERE
txt1 = 'Uniform 1D: Uni-axial stress state';
txt2 = 'Uniform 3D: Uniaxial stress state (802 steps)';

% CHOSE WHICH STRESS-STRAIN CURVE TO PLOT!
sig = 1;

% r>0 INTERPOLATE OR r<0 EXTRAPOLATE, USE DEFAULT r = 0
r = 0;

%% RUN TEST
testRateDependency(net, DefaultJobNameanalysis1, DefaultJobNameanalysis2,...
    a_11, a_22, a_33, a_12, a_13, a_23, v, txt1);
%%
[MeRE, MaRE] = modelValidator(net,...
    DefaultJobNameanalysis1, DefaultJobNameanalysis2,...
    r, a_11, a_22, a_33, a_12, a_13, a_23, v, sig, txt2);

%%
[MeRE, MaRE] = modelValidator(net,...
    DefaultJobNameanalysis1, DefaultJobNameanalysis2,...
    r, a_11, a_22, a_33, a_12, a_13, a_23, v);
%%
DATA = DefaultJobNameanalysis1';
L = length(DATA);
DATA = [repmat(a_11,1,L);repmat(a_22,1,L);repmat(a_33,1,L);repmat(a_12,1,L);repmat(a_13,1,L);repmat(a_23,1,L);repmat(v,1,L);DATA];
%%
tic
stress = predict(net,DATA,'ExecutionEnvironment','gpu');
toc