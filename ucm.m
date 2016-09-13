function fitVal = ucm(settings)
% UCM.m Run main model control for ucm.
%   Description: Settings are generated with RWEXPERIMENTSET. The model is
%   simulated based on the parameters provided in the settings.
%   
%   Author: R. Calen Walshe The University of Texas (calen.walshe@utexas.edu) (2016)


nSubjects = settings.NumberSubjects;
nTrials   = settings.NumberTrials;

humanData = load(settings.humanDataPath);

experimentData = cell(nTrials, nSubjects);

for i = 1:nSubjects
    for k = 1:nTrials
        RandomWalkParameters      = settings.InitializeRandomWalkParameters(settings);
        singleTrialData           = runSingleTrial(settings, RandomWalkParameters, k);
        experimentData{k, i}      = singleTrialData;
    end
end

eventKeys  = RandomWalkParameters.eventKeys;

fitVal      = settings.FitnessFcn(settings, eventKeys, experimentData, humanData);