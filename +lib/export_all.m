% Save data function. Must work into script. 
function export_all(settings, RandomWalkParameters, experimentDataChanges, experimentDataEvents, humanData)
    eventKeys                         = RandomWalkParameters.eventKeys;    
    export_data.experimentDataChanges = vertcat(experimentDataChanges{:});
    export_data.experimentDataEvents  = vertcat(experimentDataEvents{:});
    export_data.humanData      = humanData;
    export_data.eventKeys      = eventKeys;
    export_data.settings       = settings;

    save(['./_export/', settings.ExperimentName, '_exported.mat'], 'export_data');
end