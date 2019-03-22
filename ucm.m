function fitVal = ucm(settings)
% UCM.m Run main model control for ucm.
%   Description: Settings are generated with RWEXPERIMENTSET. The model is
%   simulated based on the parameters provided in the settings.
%   
%   Author: R. Calen Walshe The University of Texas (calen.walshe@utexas.edu) (2016)


nSubjects = settings.NumberSubjects;
nTrials   = settings.NumberTrials;

if ~isempty(settings.humanDataPath)
    humanData = load(settings.humanDataPath);
else
    humanData = [];
end

experimentDataEvents  = cell(nTrials, nSubjects);
experimentDataChanges = cell(nTrials, nSubjects);

RandomWalkParameters      = settings.InitializeRandomWalkParameters(settings);
eventKeys                 = RandomWalkParameters.eventKeys;

for i = 1:nSubjects
    parfor k = 1:nTrials
        singleTrialData           = runSingleTrial(settings, RandomWalkParameters, k);
        
        experimentDataChanges{k, i}      = singleTrialData.globalChanges;
        experimentDataEvents{k, i}       = singleTrialData.globalEvents;
    end
end

plotFcn  = settings.PlotFcn;

if ~isempty(plotFcn) 
    plotFcn(settings, eventKeys, experimentDataChanges)
    drawnow
end

export_all = settings.ExportFcn;

if ~isempty(export_all) 
    export_all(settings, RandomWalkParameters, experimentDataChanges, experimentDataEvents, humanData)
end

fitVal      = settings.FitnessFcn(settings, eventKeys, experimentDataChanges, humanData);