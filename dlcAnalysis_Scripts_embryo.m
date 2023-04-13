%% DLC Analysis Scripts for tracking movement in chicken embryo
% written by Janie Ondracek, janie.ondracek@tum.de

%% Run each block of code by pressing Cntrl + Enter

%% 1) Define analysis directory and identify csv files
% Make sure to put all the .csv files for one experiment into one directory

analysisDir = 'D:\HES714\Verhaltensparameter\HS\ED15Setup1\V15_S1_17\allcsv\'; % path to the analysis directory, should contain the .csv files
ExperimentName = 'V15_S1_17_testcluster';

addpath(genpath('C:\Users\dlc\Documents\DLCEmbryoCode'));
dlc_OBJ = dlcAnalysis_OBJ_embryo(analysisDir, ExperimentName);

%% 2) Load csv files 
tic
dlc_OBJ = loadTrackedData(dlc_OBJ);
toc

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3) Analysis
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% plot detection clusters

likelihood_cutoff  = 0.75;
SaveNameTxt = 'phalanx_distalis and tarsus_below';
dlc_OBJ = plotDetectionClusters(dlc_OBJ, likelihood_cutoff, SaveNameTxt );

%% Distance between beak parts
likelihood_cutoff  = 0.75;
dlc_Obj = plotDistanceBetweenTwoPoints(dlc_OBJ, likelihood_cutoff);

%% Angle between beak parts
likelihood_cutoff   = 0.75;
[dlc_Obj] = plotAngleBetweenThreePoints(dlc_OBJ, likelihood_cutoff);

%% Movement

likelihood_cutoff  = 0.75;
[dlc_Obj] = plotMovement(dlc_OBJ, likelihood_cutoff);

%% Other analysis
%% Raw coordinates
plot_variable_over_time(dlc_OBJ, 1) % likelihood
plot_variable_over_time(dlc_OBJ, 2) % x coordinates
plot_variable_over_time(dlc_OBJ, 3) % y coordinates

%% Velocity and heat maps
% plot velocity over time
SaveNameTxt = 'only_beak';
likelihood_cutoff  = 0.75;
dlc_Obj = plotVelocity(dlc_OBJ, SaveNameTxt, likelihood_cutoff);

%% 
%dlc_Obj = makePlotsForDistances(dlc_Obj, 2);

% Box plots,heat maps for 5 s windows
%dlc_Obj = makePlotsMeanWindowAnalysis(dlc_Obj, 2);
