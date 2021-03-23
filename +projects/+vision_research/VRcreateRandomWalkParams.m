function RandomWalkParameters = VRcreateRandomWalkParams(settings)
activeWalkLevel   = 0;
bWalkActive       = 0;
t                 = 0;
events            = [];
activeWalkLevel   = zeros(1,5);
bWalkActive       = [1 0 0 0 0];
simulateOn        = 1;
selectWalk        = 1;

maxState          = settings.NumberStates;
meanTimerDuration = settings.WalkRate;
baseRates         = maxState ./ meanTimerDuration;
rates             = baseRates;
EB_lag            = 0;
surprise_offset   = settings.ModelParams(5);
encoding_offset   = settings.ModelParams(6);

%
rateChange_up_surprise        = baseRates .* [settings.ModelParams(1), settings.ModelParams(1), settings.ModelParams(1), 1, 1];
rateChange_up_encoding        = baseRates .* [settings.ModelParams(2), settings.ModelParams(2), settings.ModelParams(2), 1, 1];
rateChange_down_surprise      = baseRates .* [settings.ModelParams(3), settings.ModelParams(3), settings.ModelParams(3), 1, 1];
rateChange_down_encoding      = baseRates .* [settings.ModelParams(4), settings.ModelParams(4), settings.ModelParams(4), 1, 1];

timerEndNum           = 1;
labileInterruptNum    = 2;
labileStartNum        = 3;
labileEndNum          = 4;
nonlabileStartNum     = 5;
nonlabileEndNum       = 6;
motorStartNum         = 7;
motorEndNum           = 8;
saccadeStartNum       = 9;
saccadeEndNum         = 10;
UP                    = 11;
DOWN                  = 12;
NOCHANGE              = 13;
UP_DUR                = 14;
DOWN_DUR              = 15;
NOCHANGE_DUR          = 16;
timerStepNum          = 17;
timerKeys             = 18;

% Set the trial event counters
nSaccade  = 0;
shiftVals = [1 2 3 1 2 3];
shiftInProgress      = 0;
shiftPendingTime     = 0;
idx                  = 0;

RandomWalkParameters = struct('activeWalkLevel', activeWalkLevel, 'bWalkActive', bWalkActive, ...,
    't', t, 'events', events,...,
    'simulateOn', simulateOn, 'selectWalk', selectWalk, 'maxState', maxState, 'meanTimerDuration', meanTimerDuration,...,
    'baseRates', baseRates, 'EB_lag', EB_lag, 'surprise_offset', surprise_offset, 'encoding_offset', encoding_offset, 'rateChange_up_surprise', rateChange_up_surprise, 'rateChange_up_encoding', rateChange_up_encoding, 'rateChange_down_surprise', rateChange_down_surprise, 'rateChange_down_encoding', rateChange_down_encoding, 'rates', rates);

eventCounters = struct('idx', idx, 'nSaccade', nSaccade, 'shiftVals', shiftVals,...
    'shiftInProgress', shiftInProgress, 'shiftPendingTime', shiftPendingTime);

eventKeys = struct('NOCHANGE_DUR', NOCHANGE_DUR, 'UP_DUR', UP_DUR', 'DOWN_DUR', DOWN_DUR, 'timerEndNum', timerEndNum, 'labileInterruptNum', labileInterruptNum, 'labileStartNum', labileStartNum,...,
    'labileEndNum', labileEndNum, 'nonlabileStartNum', nonlabileStartNum, 'nonlabileEndNum', nonlabileEndNum, 'motorStartNum', motorStartNum,...,
    'motorEndNum', motorEndNum, 'saccadeStartNum', saccadeStartNum, 'saccadeEndNum', saccadeEndNum, 'timerStepNum', timerStepNum, 'NOCHANGE', NOCHANGE, 'UP', UP, 'DOWN', DOWN, ...
    'timerKeys', timerKeys);

RandomWalkParameters.eventKeys      = eventKeys;
RandomWalkParameters.eventCounters  = eventCounters;

end