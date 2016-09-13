function [RandomWalkParameters, changeEvents, eventCounters] = VisionResearchParameterAdjustFcn(RandomWalkParameters, singleStepEvents, globalEvents, eventCounters, t)
%VISIONRESEARCHPARAMETERADJUSTFCN.m Adjusts the parameters of the random
%walk to match the processing difficulty of the currently foveated stimulus
%content.
%
% Author. R. Calen Walshe The University of Texas at Austin (2016)

changeEvents = [];

eventKeys = RandomWalkParameters.eventKeys;

if any(singleStepEvents(:,2) == eventKeys.saccadeEndNum)
    eventCounters.nSaccade = eventCounters.nSaccade + 1;    
    eventCounters.shiftPendingOn      = 1;
    eventCounters.shiftPendingTime    = t + 50;
end



if eventCounters.shiftPendingOn == 1 && t > eventCounters.shiftPendingTime
    idx         = randi(length(eventCounters.shiftVals));
    changeVal   = eventCounters.shiftVals(idx);
    
    eventCounters.shiftVals           = eventCounters.shiftVals(1:end ~= idx);
    
    if changeVal == 1
        RandomWalkParameters.rates = RandomWalkParameters.rateIncrease;
        eventCounters.direction    = 1;
        %singleStepEvents = [singleStepEvents; t, eventKeys.UP];
    elseif changeVal == 2
        RandomWalkParameters.rates = RandomWalkParameters.rateDecrease;
        eventCounters.direction    = 2;
        %singleStepEvents = [singleStepEvents; t, eventKeys.DOWN];        
    elseif changeVal == 3
        RandomWalkParameters.rates = RandomWalkParameters.rateDecrease;
        eventCounters.direction    = 3;
        %singleStepEvents = [singleStepEvents; t, eventKeys.DOWN];                
    end
    
    eventCounters.shiftPendingOn  = 0;
    eventCounters.shiftPendingOff = 1;
        
end

if any(singleStepEvents(:,2) == eventKeys.saccadeStartNum)    
    if eventCounters.shiftPendingOff == 1;
        eventCounters.shiftPendingOff = 0;
        RandomWalkParameters.rates = RandomWalkParameters.baseRates;
        saccIdx = find(globalEvents(1:end,2) == eventKeys.saccadeEndNum,1,'last');        
        fixDur  = t - globalEvents(saccIdx, 1);
        
        if eventCounters.direction == 1            
            changeEvents = [changeEvents; fixDur, eventKeys.UP_DUR];
        elseif eventCounters.direction == 2            
            changeEvents = [changeEvents; fixDur, eventKeys.DOWN_DUR];
        else
            changeEvents = [changeEvents; fixDur, eventKeys.NOCHANGE_DUR];
        end
        
        if isempty(eventCounters.shiftVals)
            RandomWalkParameters.simulateOn = 0;
        end
    end

end