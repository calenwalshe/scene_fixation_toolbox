function [RandomWalkParameters, changeEvents, eventCounters] = VisionResearchParameterAdjustFcn(RandomWalkParameters, singleStepEvents, globalEvents, eventCounters, t)
%VISIONRESEARCHPARAMETERADJUSTFCN.m Adjusts the parameters of the random
%walk to match the processing difficulty of the currently foveated stimulus
%content.
%
% Author. R. Calen Walshe The University of Texas at Austin (2016)

changeEvents = [];

eventKeys = RandomWalkParameters.eventKeys;

if ~isempty(singleStepEvents) && any(singleStepEvents(:,2) == eventKeys.saccadeEndNum)
    eventCounters.nSaccade = eventCounters.nSaccade + 1;
    if mod(eventCounters.nSaccade,5) == 0
        eventCounters.shiftInProgress     = 1;
        eventCounters.shiftPendingTime    = t + RandomWalkParameters.EB_lag;
        eventCounters.surpriseEnd         = t + RandomWalkParameters.EB_lag + RandomWalkParameters.surprise_offset;
        eventCounters.encodingStart       = t + RandomWalkParameters.encoding_offset;
        eventCounters.idx                 = randi(length(eventCounters.shiftVals));
    end
end

if eventCounters.shiftInProgress == 1 && t > eventCounters.shiftPendingTime
    changeVal   = eventCounters.shiftVals(eventCounters.idx);   
    if changeVal == 3
        %keyboard
    end
    if changeVal == 1
        if t < eventCounters.surpriseEnd
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;
        elseif t > eventCounters.encodingStart
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;
        else
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;
        end
        eventCounters.direction    = 1;
        %singleStepEvents = [singleStepEvents; t, eventKeys.UP];
    elseif changeVal == 2
        if t < eventCounters.surpriseEnd
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_up1_surprise;
        elseif t > eventCounters.encodingStart
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_up1_encoding;        
        else
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;
        end
        eventCounters.direction    = 2;

        %singleStepEvents = [singleStepEvents; t, eventKeys.DOWN];
    elseif changeVal == 3
        if t < eventCounters.surpriseEnd
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_up2_surprise;
        elseif t > eventCounters.encodingStart
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_up2_encoding;        
        else
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;
        end
        eventCounters.direction    = 3;
        %singleStepEvents = [singleStepEvents; t, eventKeys.DOWN];                
    elseif changeVal == 4
        if t < eventCounters.surpriseEnd
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_up3_surprise;
        elseif t > eventCounters.encodingStart
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_up3_encoding;        
        else
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;
        end
        eventCounters.direction    = 4;
        %singleStepEvents = [singleStepEvents; t, eventKeys.DOWN];                
    elseif changeVal == 5
        if t < eventCounters.surpriseEnd
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_up4_surprise;
        elseif t > eventCounters.encodingStart
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_up4_encoding;        
        else
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;
        end
        eventCounters.direction    = 5;
        %singleStepEvents = [singleStepEvents; t, eventKeys.DOWN];                
    end   
    
else
    return
end

if ~isempty(singleStepEvents) && any(singleStepEvents(:,2) == eventKeys.saccadeStartNum)    
    if eventCounters.shiftInProgress == 1
        eventCounters.shiftInProgress = 0;
        eventCounters.shiftVals           = eventCounters.shiftVals(1:end ~= eventCounters.idx);
        RandomWalkParameters.rates = RandomWalkParameters.rates;
        saccIdx = find(globalEvents(1:end,2) == eventKeys.saccadeEndNum,1,'last');        
        fixDur  = t - globalEvents(saccIdx, 1);
        
        if eventCounters.direction == 1
            changeEvents = [changeEvents; fixDur, eventKeys.NOCHANGE_DUR];
        elseif eventCounters.direction == 2
            changeEvents = [changeEvents; fixDur, eventKeys.UP1_DUR];
        elseif eventCounters.direction == 3
            changeEvents = [changeEvents; fixDur, eventKeys.UP2_DUR];
        elseif eventCounters.direction == 4
            changeEvents = [changeEvents; fixDur, eventKeys.UP3_DUR];
        elseif eventCounters.direction == 5
            changeEvents = [changeEvents; fixDur, eventKeys.UP4_DUR];            
        else
            error('Wrong change number')
        end
        
        if isempty(eventCounters.shiftVals)
            RandomWalkParameters.simulateOn = 0;
        end
    end

end