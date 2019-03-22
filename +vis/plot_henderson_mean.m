function plot_henderson_mean(settings, eventKeys, model_data)


UP1key       = eventKeys.UP1_DUR;
UP2key       = eventKeys.UP2_DUR;
UP3key       = eventKeys.UP3_DUR;
UP4key       = eventKeys.UP4_DUR;

NOCHANGEkey = eventKeys.NOCHANGE_DUR;

simulationData = cell2mat(model_data);
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

bar([hend_nochange(1),meanNOCHANGE;hend_up1(1),meanUP1;hend_up2(1),meanUP2;hend_up3(1),meanUP3;hend_up4(1),meanUP4(1)])

display([hend_nochange(1),meanNOCHANGE;hend_up1(1),meanUP1;hend_up2(1),meanUP2;hend_up3(1),meanUP3;hend_up4(1),meanUP4(1)]);

end