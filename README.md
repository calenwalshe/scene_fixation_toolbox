# Creating random walk models of fixation durations during scene viewing.
A toolbox for creating random walk models of fixation durations during scene viewing.

Here is a quick start:

```matlab
WalkRate     = [230.25, 192.23, 83.66, 30	20];
NumberStates = [16, 16, 16, 16, 16];
ModelParams  = [0.53, 1, 0.14, 0.61, 60.56, 247.19];
    
settings_exp1 = lib.rwexperimentset('ExperimentName', 'visionresearch_exp1',...
        'humanDataPath', '_data/h_fixdur_exp1.mat', 'NumberTrials', 1500,...
        'NumberStates', NumberStates, 'WalkRate', WalkRate,...
        'ModelParams', ModelParams,...
        'EventDrivenChangeFcn', @projects.vision_research.VisionResearchParameterAdjustFcn, 'FitnessFcn',...
        @lib.VRMaxLik_baseline, 'NumberSubjects', 1, 'InitializeRandomWalkParameters',...
        @projects.vision_research.VRcreateRandomWalkParams);
    
f = ucm(settings_exp1);
```




