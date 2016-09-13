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

timerIdx        = 1;
labileIdx       = 2;
nonlabileIdx    = 3;
motorIdx        = 4;
saccadeIdx      = 5;

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


globalEvents  = zeros(1,2);   
globalChanges = zeros(1,2);   
t            = 0; 

while RandomWalkParameters.simulateOn
    singleStepEvents = zeros(1,2);
    switch RandomWalkParameters.selectWalk
        case timerIdx
            if RandomWalkParameters.activeWalkLevel(timerIdx) == RandomWalkParameters.maxState(timerIdx)
                singleStepEvents = [singleStepEvents;t timerEndNum]; %#ok<*AGROW>
                RandomWalkParameters.activeWalkLevel(timerIdx)       = 0;
                singleStepEvents = [singleStepEvents;t labileStartNum];
                
                if RandomWalkParameters.bWalkActive(labileIdx);
                    singleStepEvents = [singleStepEvents;t labileInterruptNum];
                    
                    RandomWalkParameters.activeWalkLevel(timerIdx)       = 0;
                    RandomWalkParameters.activeWalkLevel(labileIdx)      = 0;
                end
                
                RandomWalkParameters.bWalkActive(labileIdx)          = 1;
            end
        case labileIdx
            if RandomWalkParameters.activeWalkLevel(labileIdx) == RandomWalkParameters.maxState(labileIdx)
                    singleStepEvents = [singleStepEvents;t labileEndNum];
                    RandomWalkParameters.bWalkActive(labileIdx)          = 0;
                    RandomWalkParameters.activeWalkLevel(labileIdx)      = 0;
                if ~RandomWalkParameters.bWalkActive(nonlabileIdx)
                    singleStepEvents = [singleStepEvents;t nonlabileStartNum];
                    RandomWalkParameters.bWalkActive(nonlabileIdx)          = 1;
                end
            end
        case nonlabileIdx
            if RandomWalkParameters.activeWalkLevel(nonlabileIdx) == RandomWalkParameters.maxState(nonlabileIdx)
                singleStepEvents = [singleStepEvents;t nonlabileEndNum];
                RandomWalkParameters.activeWalkLevel(nonlabileIdx)       = 0;
                RandomWalkParameters.bWalkActive(nonlabileIdx)           = 0;
                
                if ~RandomWalkParameters.bWalkActive(motorIdx)
                    singleStepEvents = [singleStepEvents;t motorStartNum];
                    RandomWalkParameters.bWalkActive(motorIdx)           = 1;
                end
            end
        case motorIdx
            if RandomWalkParameters.activeWalkLevel(motorIdx) == RandomWalkParameters.maxState(motorIdx)
                singleStepEvents = [singleStepEvents;t motorEndNum];
                RandomWalkParameters.activeWalkLevel(motorIdx)       = 0;
                RandomWalkParameters.bWalkActive(motorIdx)           = 0;
                
                if ~RandomWalkParameters.bWalkActive(saccadeIdx)
                    singleStepEvents = [singleStepEvents;t saccadeStartNum];
                    RandomWalkParameters.bWalkActive(saccadeIdx) = 1;
                end
            end                        
        case saccadeIdx
            if RandomWalkParameters.activeWalkLevel(saccadeIdx) == RandomWalkParameters.maxState(saccadeIdx)
                singleStepEvents = [singleStepEvents;t saccadeEndNum];
                RandomWalkParameters.activeWalkLevel(saccadeIdx)       = 0;
                RandomWalkParameters.bWalkActive(saccadeIdx)           = 0;
            end                        
    end

    RandomWalkParameters.globalRate                 = sum(RandomWalkParameters.rates .* RandomWalkParameters.bWalkActive);
    t               = t + ((-1/RandomWalkParameters.globalRate*log(1-rand)));  
    
    RandomWalkParameters.transitionProbability      = ...
        RandomWalkParameters.rates .* RandomWalkParameters.bWalkActive ./ RandomWalkParameters.globalRate;
    
    RandomWalkParameters.selectWalk                 = randsample(5, 1, true, RandomWalkParameters.transitionProbability);

    RandomWalkParameters.activeWalkLevel(RandomWalkParameters.selectWalk) = ...
        RandomWalkParameters.activeWalkLevel(RandomWalkParameters.selectWalk) + 1;   

    [RandomWalkParameters, changeEvents, eventCounters] = settings.EventDrivenChangeFcn(RandomWalkParameters, singleStepEvents, globalEvents, eventCounters, t);
    globalEvents                                  = [globalEvents; singleStepEvents];
    globalChanges                                 = [globalChanges; changeEvents];
end

singleTrialData = globalChanges;