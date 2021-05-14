function VRMaxLik_adaptation(settings, eventKeys, experimentData, humanData)
%% Plot some data

events         = vertcat(experimentData{:});

if isempty(events)
    NLL = 10000;
    return;
end
event_objects  = events(:,1);
%
% Extract Fixation Durations %
fix_dur_idx  = cellfun(@(x) any(x(1) == [eventKeys.NOCHANGE_DUR,eventKeys.UP_DUR,eventKeys.DOWN_DUR]), event_objects);

simulationData = vertcat(event_objects{fix_dur_idx});
% 

UPkey       = eventKeys.UP_DUR;
DOWNkey     = eventKeys.DOWN_DUR;
NOCHANGEkey = eventKeys.NOCHANGE_DUR;

h_data_nochange = humanData.human_data(humanData.human_data(:,1) == 1,2);
h_data_up       = humanData.human_data(humanData.human_data(:,1) == 2,2);
h_data_down     = humanData.human_data(humanData.human_data(:,1) == 3,2);

dataDOWN       = simulationData(simulationData(1:end,1) == DOWNkey,2);
dataUP         = simulationData(simulationData(1:end,1) == UPkey,2);
dataNOCHANGE   = simulationData(simulationData(1:end,1) == NOCHANGEkey,2);

edges = 0:60:1200;

dataNOCHANGE_bin = histc(dataNOCHANGE, edges) + 1; % maximum likelihood doesn't like log(0) so add 1
dataNOCHANGE_bin = dataNOCHANGE_bin(1:(end - 1));
dataNOCHANGE_P   = dataNOCHANGE_bin/sum(dataNOCHANGE_bin);

dataUP_bin = histc(dataUP, edges) + 1;
dataUP_bin = dataUP_bin(1:(end - 1));
dataUP_P   = dataUP_bin/sum(dataUP_bin);

dataDOWN_bin = histc(dataDOWN, edges) + 1;
dataDOWN_bin = dataDOWN_bin(1:(end-1));
dataDOWN_P   = dataDOWN_bin/sum(dataDOWN_bin);

figure;subplot(1,3,1);axis square
plot(30:60:1170, dataNOCHANGE_P);hold on;plot(30:60:1170, h_data_nochange);axis square

hold off
subplot(1,3,2);axis square
plot(30:60:1170, dataUP_P);hold on;plot(30:60:1170, h_data_up);axis square

hold off
subplot(1,3,3);axis square
plot(30:60:1170, dataDOWN_P);hold on;plot(30:60:1170, h_data_down);axis square
end
