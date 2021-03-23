function singleTrialData = runSingleTrial(settings, RandomWalkParameters, trialNr)
%RUNSINGLETRIAL Run a single trial of the simulation model.
% Description: 
%   Each simulation experiment consists of a sequence of trials. Each
%   trial generates data. The trial is simulated in this script and the
%   results are returned.
%
% Example: 
%   [singleTrialData] = SINGLETRIALDETECTION(TrialParameters, trialNr);
%   
%   See also 
%
% v1.0, 3/8/2016, R.C. Walshe (calen.walshe@gmail.com)

if ~exist('settings','var') || nargin < 1    
    TrialParameters.eventDrivenChangeFcn        = @VisionResearchParameterAdjustFcn;
    TrialParameters.RandomWalkParameters        = demoCreateRandomWalkParams();
    trialNr                                     = 1;        
end

%fileID = fopen('~/Dropbox/Calen/Dropbox/exp.txt','a');

timerIdx        = 1;
labileIdx       = 2;
nonlabileIdx    = 3;
motorIdx        = 4;
saccadeIdx      = 5;

timerStepNum         = RandomWalkParameters.eventKeys.timerStepNum;
timerEndNum          = RandomWalkParameters.eventKeys.timerEndNum;
labileInterruptNum   = RandomWalkParameters.eventKeys.labileInterruptNum;
labileStartNum       = RandomWalkParameters.eventKeys.labileStartNum;
labileEndNum         = RandomWalkParameters.eventKeys.labileEndNum;
nonlabileStartNum    = RandomWalkParameters.eventKeys.nonlabileStartNum;
nonlabileEndNum      = RandomWalkParameters.eventKeys.nonlabileEndNum;
motorStartNum        = RandomWalkParameters.eventKeys.motorStartNum;
motorEndNum          = RandomWalkParameters.eventKeys.motorEndNum;
saccadeStartNum      = RandomWalkParameters.eventKeys.saccadeStartNum;
saccadeEndNum        = RandomWalkParameters.eventKeys.saccadeEndNum;

eventCounters = RandomWalkParameters.eventCounters;

globalEvents  = [];   
globalChanges = [];
t            = 0; 

cancelCounter = 0;

while RandomWalkParameters.simulateOn
    singleStepEvents = [];
    if cancelCounter > 50
        singleTrialData.globalChanges = [];
        singleTrialData.globalEvents  = [];
        return
    end
    switch RandomWalkParameters.selectWalk
        case timerIdx
            if RandomWalkParameters.activeWalkLevel(timerIdx) == RandomWalkParameters.maxState(timerIdx)
                RandomWalkParameters.activeWalkLevel(timerIdx)       = 0;
                singleStepEvents = [singleStepEvents; [timerEndNum, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]];
                singleStepEvents = [singleStepEvents; [labileStartNum, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]];
                
                if RandomWalkParameters.bWalkActive(labileIdx)
                    singleStepEvents = [singleStepEvents; [labileInterruptNum, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]];
                    
                    RandomWalkParameters.activeWalkLevel(timerIdx)       = 0;
                    RandomWalkParameters.activeWalkLevel(labileIdx)      = 0;
                    
                    cancelCounter = cancelCounter + 1;
                end
                
                RandomWalkParameters.bWalkActive(labileIdx)              = 1;
            end
        case labileIdx
            if RandomWalkParameters.activeWalkLevel(labileIdx) == RandomWalkParameters.maxState(labileIdx)
                    singleStepEvents = [singleStepEvents; [labileEndNum, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]];
                    RandomWalkParameters.bWalkActive(labileIdx)          = 0;
                    RandomWalkParameters.activeWalkLevel(labileIdx)      = 0;
                if ~RandomWalkParameters.bWalkActive(nonlabileIdx)
                    singleStepEvents = [singleStepEvents; [nonlabileStartNum, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]];
                    RandomWalkParameters.bWalkActive(nonlabileIdx)       = 1;
                end
            end
        case nonlabileIdx
            if RandomWalkParameters.activeWalkLevel(nonlabileIdx) == RandomWalkParameters.maxState(nonlabileIdx)
                singleStepEvents = [singleStepEvents; [nonlabileEndNum, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]];
                RandomWalkParameters.activeWalkLevel(nonlabileIdx)       = 0;
                RandomWalkParameters.bWalkActive(nonlabileIdx)           = 0;
                
                if ~RandomWalkParameters.bWalkActive(motorIdx)
                    singleStepEvents = [singleStepEvents; [motorStartNum, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]];
                    RandomWalkParameters.bWalkActive(motorIdx)           = 1;
                end
            end
        case motorIdx
            if RandomWalkParameters.activeWalkLevel(motorIdx) == RandomWalkParameters.maxState(motorIdx)
                singleStepEvents = [singleStepEvents; [motorEndNum, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]];
                RandomWalkParameters.activeWalkLevel(motorIdx)       = 0;
                RandomWalkParameters.bWalkActive(motorIdx)           = 0;
                
                if ~RandomWalkParameters.bWalkActive(saccadeIdx)
                    singleStepEvents = [singleStepEvents; [saccadeStartNum, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]];
                    RandomWalkParameters.bWalkActive(saccadeIdx)     = 1;
                end
            end                        
        case saccadeIdx
            if RandomWalkParameters.activeWalkLevel(saccadeIdx) == RandomWalkParameters.maxState(saccadeIdx)
                singleStepEvents = [singleStepEvents; [saccadeEndNum, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]];
                RandomWalkParameters.activeWalkLevel(saccadeIdx)     = 0;
                RandomWalkParameters.bWalkActive(saccadeIdx)         = 0;
                cancelCounter = 0;
            end
    end

    [RandomWalkParameters, changeEvents, eventCounters] = settings.EventDrivenChangeFcn(RandomWalkParameters,...
        singleStepEvents, globalEvents, eventCounters, t, trialNr);
    
    if ~isempty(singleStepEvents)
        globalEvents = [globalEvents; singleStepEvents];
    end
    
    if ~isempty(changeEvents)
        globalChanges                                 = [globalChanges; changeEvents];
    end    
    
    RandomWalkParameters.globalRate                 = sum(RandomWalkParameters.rates .* RandomWalkParameters.bWalkActive);
    t               = t + ((-1/RandomWalkParameters.globalRate*log(1-rand)));
    
    RandomWalkParameters.transitionProbability      = ...
        RandomWalkParameters.rates .* RandomWalkParameters.bWalkActive ./ RandomWalkParameters.globalRate;
        
    RandomWalkParameters.selectWalk                 = randsample(5, 1, true, RandomWalkParameters.transitionProbability);
    
    RandomWalkParameters.activeWalkLevel(RandomWalkParameters.selectWalk) = ...
        RandomWalkParameters.activeWalkLevel(RandomWalkParameters.selectWalk) + 1;
    
    outputMat = [RandomWalkParameters.activeWalkLevel, RandomWalkParameters.rates, t, trialNr];
        
    %fprintf(fileID, [num2str(outputMat), '\n']);
    
end
singleTrialData.globalChanges = globalChanges;
singleTrialData.globalEvents  = globalEvents;