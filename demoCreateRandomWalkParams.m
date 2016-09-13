function RandomWalkParameters = demoCreateRandomWalkParams(settings)

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

rateIncrease      = baseRates .* [1 1.6 1.6 1 1 ];
rateDecrease      = baseRates .* [1 1 1 1 1];

timerEndNum          = 1;
labileInterruptNum   = 2;
labileStartNum       = 3;
labileEndNum         = 4;
nonlabileStartNum    = 5;
nonlabileEndNum      = 6;
motorStartNum        = 7;
motorEndNum          = 8;
saccadeStartNum      = 9;
saccadeEndNum        = 10;
UP                   = 11;
DOWN                 = 12;
UP_DUR               = 13;
DOWN_DUR             = 14;
NOCHANGE_DUR         = 15;

% Set the trial event counters
nSaccade  = 0;
shiftVals = [1 2 3 1 2 3];
shiftPendingOn       = 0;
shiftPendingOff      = 0;
shiftPendingTime     = 0;

RandomWalkParameters = struct('activeWalkLevel', activeWalkLevel, 'bWalkActive', bWalkActive, ...,
    't', t, 'events', events,...,
    'simulateOn', simulateOn, 'selectWalk', selectWalk, 'maxState', maxState, 'meanTimerDuration', meanTimerDuration,...,
    'baseRates', baseRates, 'rateIncrease', rateIncrease, 'rateDecrease', rateDecrease, 'rates', rates);

eventCounters = struct('nSaccade', nSaccade, 'shiftVals', shiftVals,...
    'shiftPendingOn', shiftPendingOn, 'shiftPendingOff', shiftPendingOff, 'shiftPendingTime', shiftPendingTime);

eventKeys = struct('NOCHANGE_DUR', NOCHANGE_DUR, 'UP_DUR', UP_DUR', 'DOWN_DUR', DOWN_DUR, 'timerEndNum', timerEndNum, 'labileInterruptNum', labileInterruptNum, 'labileStartNum', labileStartNum,...,
    'labileEndNum', labileEndNum, 'nonlabileStartNum', nonlabileStartNum, 'nonlabileEndNum', nonlabileEndNum, 'motorStartNum', motorStartNum,...,
    'motorEndNum', motorEndNum, 'saccadeStartNum', saccadeStartNum, 'saccadeEndNum', saccadeEndNum, 'UP', UP, 'DOWN', DOWN);

RandomWalkParameters.eventKeys      = eventKeys;
RandomWalkParameters.eventCounters  = eventCounters;

end