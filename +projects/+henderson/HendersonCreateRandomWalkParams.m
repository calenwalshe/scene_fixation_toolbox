function RandomWalkParameters = HendersonCreateRandomWalkParams(settings)

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
EB_lag            = 30;
surprise_offset   = 98;
encoding_offset   = 244;
%
rateChange_up1_surprise        = baseRates .* [1, settings.ModelParams(1), settings.ModelParams(1), 1, 1];
rateChange_up1_encoding        = baseRates .* [1, settings.ModelParams(2), settings.ModelParams(2), 1, 1];
rateChange_up2_surprise        = baseRates .* [1, settings.ModelParams(1), settings.ModelParams(1), 1, 1];
rateChange_up2_encoding        = baseRates .* [1, settings.ModelParams(3), settings.ModelParams(3), 1, 1];
rateChange_up3_surprise        = baseRates .* [1, settings.ModelParams(1), settings.ModelParams(1), 1, 1];
rateChange_up3_encoding        = baseRates .* [1, settings.ModelParams(4), settings.ModelParams(4), 1, 1];
rateChange_up4_surprise        = baseRates .* [1, settings.ModelParams(1), settings.ModelParams(1), 1, 1];
rateChange_up4_encoding        = baseRates .* [1, settings.ModelParams(5), settings.ModelParams(5), 1, 1];

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
UP1                  = 11;
UP2                  = 12;
UP3                  = 13;
UP4                  = 14;
UP1_DUR              = 15;
UP2_DUR              = 16;
UP3_DUR              = 17;
UP4_DUR              = 18;
NOCHANGE_DUR         = 19;
timerStepNum         = 20;

% Set the trial event counters
nSaccade  = 0;
shiftVals = [1 2 3 4 5 1 2 3 4 5];
shiftInProgress      = 0;
shiftPendingTime     = 0;
idx                  = 0;

RandomWalkParameters = struct('activeWalkLevel', activeWalkLevel, 'bWalkActive', bWalkActive, ...,
    't', t, 'events', events,...,
    'simulateOn', simulateOn, 'selectWalk', selectWalk, 'maxState', maxState, 'meanTimerDuration', meanTimerDuration,...,
    'baseRates', baseRates, 'EB_lag', EB_lag, 'surprise_offset', surprise_offset, 'encoding_offset', encoding_offset,...
    'rateChange_up1_surprise', rateChange_up1_surprise,...
    'rateChange_up1_encoding', rateChange_up1_encoding,...
    'rateChange_up2_surprise', rateChange_up2_surprise,...
    'rateChange_up2_encoding', rateChange_up2_encoding,...
    'rateChange_up3_surprise', rateChange_up3_surprise,...
    'rateChange_up3_encoding', rateChange_up3_encoding,...
    'rateChange_up4_surprise', rateChange_up4_surprise,...
    'rateChange_up4_encoding', rateChange_up4_encoding,...
    'rates', rates);

eventCounters = struct('idx', idx, 'nSaccade', nSaccade, 'shiftVals', shiftVals,...
    'shiftInProgress', shiftInProgress, 'shiftPendingTime', shiftPendingTime);

eventKeys = struct('NOCHANGE_DUR', NOCHANGE_DUR,...
    'UP1_DUR', UP1_DUR',...
    'UP2_DUR', UP2_DUR',...
    'UP3_DUR', UP3_DUR',...
    'UP4_DUR', UP4_DUR',...
    'timerEndNum', timerEndNum, 'labileInterruptNum', labileInterruptNum, 'labileStartNum', labileStartNum,...,
    'labileEndNum', labileEndNum, 'nonlabileStartNum', nonlabileStartNum, 'nonlabileEndNum', nonlabileEndNum, 'motorStartNum', motorStartNum,...,
    'motorEndNum', motorEndNum, 'saccadeStartNum', saccadeStartNum, 'saccadeEndNum', saccadeEndNum, 'timerStepNum', timerStepNum, 'UP1', UP1, 'UP2', UP2, 'UP3', UP3, 'UP4', UP4);

RandomWalkParameters.eventKeys      = eventKeys;
RandomWalkParameters.eventCounters  = eventCounters;

end