% Run bads
load('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_export/settings_exp2.mat')
load('~/Dropbox/Calen/Work/ucm/scene_fixation_model/_export/settings_exp1.mat')

%Fit Adaptation
adaptation_fits_exp2 = [];
for i = 1:5
    %params   = [10 [best_baseline_exp2(2:6)], [.1 + .9 * rand,1 + rand, .1 + .9 * rand, .1 + .9 * rand], 40, 10000];
    %LB        = [10, best_baseline_exp2(2:6), [.1, 1, .1, .1], 40,  10000];
    %UB        = [10, best_baseline_exp2(2:6), [1, 2, 1, 1], 40, 10000];
    params   = [10, [best_baseline_exp2(2:6)], [.1 + .9 * rand,1, .1 + .9 * rand, .1 + .9 * rand], 100, 400];
    LB        = [5, [100, 50  70  30 20], [.1, 1, .1, .1], 10,  200];
    UB        = [20, [400, 300 90 30 20], [1, 1, 1, 1], 200, 2000];    
    [X_adaptation_exp2,FVAL] = bads(@optim.vision_research.objVR_exp2_adaptation,params,LB,UB);
    adaptation_fits_exp2     = [adaptation_fits_exp2; [X_adaptation_exp2, FVAL]];
end

[Y, I]        = min(adaptation_fits_exp2(:,end));
best_adaptation_exp2 = adaptation_fits_exp2(I,1:end-1); % minimum -LL
% Visualize Fit
%Experiment 1
WalkRate   = best_adaptation_exp2(2:6);        
WalkParams_exp2 = best_adaptation_exp2(7:end);
settings_exp2 = lib.rwexperimentset('ExperimentName', 'visionresearch_exp2',...
    'humanDataPath', '_data/h_fixdur_exp2.mat', 'NumberTrials', 10000,...
    'NumberStates', round([best_adaptation_exp2(1), repmat(round(best_adaptation_exp2(1)), 1,4)]), 'WalkRate', WalkRate,...
    'ModelParams', WalkParams_exp2,...
    'EventDrivenChangeFcn', @projects.vision_research.VisionResearchParameterAdjustFcn, 'FitnessFcn',...
    @lib.VRMaxLik_adaptation, 'NumberSubjects', 1, 'InitializeRandomWalkParameters',...
    @projects.vision_research.VRcreateRandomWalkParams, 'ExportFcn', @lib.export_all);

f_exp2 = ucm(settings_exp2);

% Counterfactuals
% No surprise
settings_exp2_no_surprise = settings_exp2;
settings_exp2_no_surprise.ModelParams([1,2]) = 1; % 
settings_exp2_no_surprise.ExperimentName = 'visionresearch_exp2_nosurprise';

f_exp2 = ucm(settings_exp2_no_surprise);

% No encoding
settings_exp2_no_encoding = settings_exp2;
settings_exp2_no_encoding.ModelParams([3,4]) = 1; % 
settings_exp2_no_encoding.ExperimentName = 'visionresearch_exp2_noencoding';
f_exp2 = ucm(settings_exp2_no_encoding);

