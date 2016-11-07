function NLL = NLL(settings, eventKeys, experimentData, humanData)
%% fitVal = MaxLik(settings, eventKeys, humanData)
% Description: This function will give the log-likelihood of the model
% given the data that human data. The aim is to search for model parameters
% that maximize the log-likelihood.
   
UPkey       = eventKeys.UP_DUR;
DOWNkey     = eventKeys.DOWN_DUR;
NOCHANGEkey = eventKeys.NOCHANGE_DUR;

h_data_nochange = humanData.human_data(humanData.human_data(:,1) == 1,2);
h_data_up = humanData.human_data(humanData.human_data(:,1) == 2,2);
h_data_down = humanData.human_data(humanData.human_data(:,1) == 3,2);

simulationData = cell2mat(experimentData);
dataDOWN = simulationData(simulationData(1:end,2) == DOWNkey);
dataUP   = simulationData(simulationData(1:end,2) == UPkey);
dataNOCHANGE   = simulationData(simulationData(1:end,2) == NOCHANGEkey);

edges = 30:60:1170;

dataNOCHANGE_bin = histc(dataNOCHANGE, edges);
dataNOCHANGE_P = dataNOCHANGE_bin/sum(dataNOCHANGE_bin);

dataUP_bin = histc(dataUP, edges);
dataUP_P = dataUP_bin/sum(dataUP_bin);

dataDOWN_bin = histc(dataDOWN, edges);
dataDOWN_P = dataDOWN_bin/sum(dataDOWN_bin);


min_p_const = 1/10^5; % very low value to avoid computing log(0)
NLL = -sum(h_data_down .* log(dataDOWN_P + min_p_const)) + ...
    -sum(h_data_nochange .* log(dataNOCHANGE_P + min_p_const)) + ...
    -sum(h_data_up .* log(dataUP_P + min_p_const));

end