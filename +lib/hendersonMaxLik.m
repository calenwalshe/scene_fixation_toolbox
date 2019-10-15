function NLL = hendersonMaxLik(settings, eventKeys, experimentData, humanData)
%% fitVal = MaxLik(settings, eventKeys, humanData)
% Description: This function will give the log-likelihood of the model
% given the data that human data. The aim is to search for model parameters
% that maximize the log-likelihood.

UP1key       = eventKeys.UP1_DUR;
UP2key       = eventKeys.UP2_DUR;
UP3key       = eventKeys.UP3_DUR;
UP4key       = eventKeys.UP4_DUR;

NOCHANGEkey = eventKeys.NOCHANGE_DUR;

simulationData = cell2mat(experimentData);
meanUP1   = mean(simulationData(simulationData(1:end,2) == UP1key));
meanUP2   = mean(simulationData(simulationData(1:end,2) == UP2key));
meanUP3   = mean(simulationData(simulationData(1:end,2) == UP3key));
meanUP4   = mean(simulationData(simulationData(1:end,2) == UP4key));
meanNOCHANGE   = mean(simulationData(simulationData(1:end,2) == NOCHANGEkey));

sdUP1   = std(simulationData(simulationData(1:end,2) == UP1key));
sdUP2   = std(simulationData(simulationData(1:end,2) == UP2key));
sdUP3   = std(simulationData(simulationData(1:end,2) == UP3key));
sdUP4   = std(simulationData(simulationData(1:end,2) == UP4key));
sdNOCHANGE   = std(simulationData(simulationData(1:end,2) == NOCHANGEkey));

hend_nochange = [407, 223];
hend_up1 = [401, 232];
hend_up2 = [396, 232];
hend_up3 = [384, 219];
hend_up4 = [290, 155];

%meanNOCHANGE = 407;
%meanUP1 = 401;
%meanUP2 = 396;
%meanUP3 = 384;
%meanUP4 = 290;

logLik = ...
    log(normpdf(hend_nochange(1),  meanNOCHANGE, sdNOCHANGE)) + ... 
    log(normpdf(hend_up1(1),  meanUP1, sdUP1)) + ... 
    log(normpdf(hend_up2(1),  meanUP2, sdUP2)) + ... 
    log(normpdf(hend_up3(1),  meanUP3, sdUP3)) + ... 
    log(normpdf(hend_up4(1),  meanUP4, sdUP4));

NLL = -logLik;

end