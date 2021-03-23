function [RandomWalkParameters, changeEvents, eventCounters] = VisionResearchParameterAdjustFcn(RandomWalkParameters, singleStepEvents, globalEvents, eventCounters, t, trialNr)
%VISIONRESEARCHPARAMETERADJUSTFCN.m Adjusts the parameters of the random
%walk to match the processing difficulty of the currently foveated stimulus
%content.
%
% Author. R. Calen Walshe The University of Texas at Austin (2016)

changeEvents = [];

eventKeys = RandomWalkParameters.eventKeys;
if ~isempty(singleStepEvents) && any(singleStepEvents(:,1) == eventKeys.saccadeEndNum)
    eventCounters.nSaccade = eventCounters.nSaccade + 1;        
    if mod(eventCounters.nSaccade,5) == 0 && eventCounters.shiftInProgress == 0        
        eventCounters.shiftInProgress     = 1;
        eventCounters.shiftPendingTime    = t + RandomWalkParameters.EB_lag;
        eventCounters.surpriseStart       = t;
        eventCounters.surpriseEnd         = eventCounters.surpriseStart + RandomWalkParameters.surprise_offset;
        eventCounters.encodingStart       = eventCounters.surpriseEnd + RandomWalkParameters.encoding_offset;
        eventCounters.encodingEnd         = Inf; %eventCounters.encodingStart + RandomWalkParameters.encoding_offset;
        eventCounters.idx                 = randi(length(eventCounters.shiftVals));
        changeVal                         = eventCounters.shiftVals(eventCounters.idx);

        switch changeVal
            case 1
                changeEvents     = [changeEvents; {[eventKeys.NOCHANGE, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]}];
            case 2                
                changeEvents     = [changeEvents; {[eventKeys.UP, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]}];
            case 3
                changeEvents     = [changeEvents; {[eventKeys.DOWN, RandomWalkParameters.activeWalkLevel./RandomWalkParameters.maxState, RandomWalkParameters.bWalkActive, t, trialNr]}];
            otherwise               
        end        
    end
end
if eventCounters.shiftInProgress == 1 && t > eventCounters.shiftPendingTime
    changeVal   = eventCounters.shiftVals(eventCounters.idx);      
    if changeVal == 1
        if (t > eventCounters.surpriseStart) && (t < eventCounters.surpriseEnd)
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;           
        elseif (t > eventCounters.encodingStart) && (t < eventCounters.encodingEnd)
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;
        else
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;                 
        end        
        eventCounters.direction    = 1;
    elseif changeVal == 2
        if (t > eventCounters.surpriseStart) && (t < eventCounters.surpriseEnd)
            display(RandomWalkParameters.rateChange_up_surprise)
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_up_surprise;
        elseif (t > eventCounters.encodingStart) && (t < eventCounters.encodingEnd)
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_up_encoding;        
        else
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;
        end
        eventCounters.direction    = 2;
    elseif changeVal == 3
        if (t > eventCounters.surpriseStart) && (t < eventCounters.surpriseEnd)
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_down_surprise;
        elseif (t > eventCounters.encodingStart) && (t < eventCounters.encodingEnd)
            RandomWalkParameters.rates = RandomWalkParameters.rateChange_down_encoding;
        else
            RandomWalkParameters.rates = RandomWalkParameters.baseRates;
        end
        eventCounters.direction    = 3;
    end   
else
    return
end

if ~isempty(singleStepEvents) && any(singleStepEvents(:,1) == eventKeys.saccadeStartNum)    
    if eventCounters.shiftInProgress == 1
        eventCounters.shiftInProgress = 0;
        eventCounters.shiftVals           = eventCounters.shiftVals(1:end ~= eventCounters.idx);
        RandomWalkParameters.rates = RandomWalkParameters.rates;
        saccIdx = find(globalEvents(1:end,1) == eventKeys.saccadeEndNum,1,'last');
        fixDur  = t - globalEvents(saccIdx, 12);
        
        if eventCounters.direction == 1
            changeEvents = [changeEvents; {[eventKeys.NOCHANGE_DUR, fixDur, t, trialNr]}];
        elseif eventCounters.direction == 2
            changeEvents = [changeEvents; {[eventKeys.UP_DUR, fixDur, t, trialNr]}];
        else
            changeEvents = [changeEvents; {[eventKeys.DOWN_DUR, fixDur, t, trialNr]}];
        end
        
        if isempty(eventCounters.shiftVals)
            RandomWalkParameters.simulateOn = 0;
        end
    end
end