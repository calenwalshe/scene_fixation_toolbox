function save_plot(settings, eventKeys, model_data)
    UPkey       = eventKeys.UP_DUR;
    DOWNkey     = eventKeys.DOWN_DUR;
    NOCHANGEkey = eventKeys.NOCHANGE_DUR;

    edges = 0:30:1200;
    
    simulationData = cell2mat(model_data);
    dataDOWN = simulationData(simulationData(1:end,2) == DOWNkey);
    dataUP   = simulationData(simulationData(1:end,2) == UPkey);
    dataNOCHANGE   = simulationData(simulationData(1:end,2) == NOCHANGEkey);

    dataNOCHANGE_bin = histc(dataNOCHANGE, edges);
    dataNOCHANGE_P = dataNOCHANGE_bin/sum(dataNOCHANGE_bin);

    dataUP_bin = histc(dataUP, edges);
    dataUP_P = dataUP_bin/sum(dataUP_bin);

    dataDOWN_bin = histc(dataDOWN, edges);
    dataDOWN_P = dataDOWN_bin/sum(dataDOWN_bin);        
    
    humanData = load(settings.humanDataPath);
    h_data_nochange = humanData.human_data(humanData.human_data(:,1) == 1,2);
    h_data_up = humanData.human_data(humanData.human_data(:,1) == 2,2);
    h_data_down = humanData.human_data(humanData.human_data(:,1) == 3,2);
   
    close all
    h = figure;set(h, 'Visible', 'off');
    subplot(2,3,1)
    model1 = bar(h_data_nochange, 'blue');
    model1.FaceAlpha = .5;    
    hold on
    model2 = bar(dataNOCHANGE_P, 'red');
    model2.FaceAlpha = .5;
    ylim([0,.4])
    xlim([0,40])
    %
    subplot(2,3,2)
    model1 = bar(h_data_up, 'blue');
    model1.FaceAlpha = .5;
    hold on
    model2 = bar(dataUP_P, 'red');
    model2.FaceAlpha = .5;    
    ylim([0,.4])
    xlim([0,40])
    %
    subplot(2,3,3)
    model1 = bar(h_data_down, 'blue');
    model1.FaceAlpha = .5;
    hold on
    model2 = bar(dataDOWN_P, 'red');
    model2.FaceAlpha = .5;
    ylim([0,.4])
    xlim([0,40])  
    
    subplot(2,3,4)
    model1 = bar(dataNOCHANGE_P, 'blue');
    model1.FaceAlpha = .5;
    hold on
    model2 = bar(dataDOWN_P, 'red');
    model2.FaceAlpha = .5;
    hold on
    model2 = bar(dataUP_P, 'green');
    model2.FaceAlpha = .5;
    ylim([0,.4])
    xlim([0,40])
    
    
    saveas(h,'~/Dropbox/Calen/Dropbox/scene_fix_fig.png');    
    
end