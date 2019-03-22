# Creating random walk models of fixation durations during scene viewing.
A toolbox for creating random walk models of fixation durations during scene viewing.

Here is a quick start method:

```matlab
settings = lib.rwexperimentset('ExperimentName', 'visionresearch', 'humanDataPath', '_data/h_fixdur_exp2.mat', 'NumberTrials', 100, 'NumberStates', [38, 10, 10, 10, 10], 'WalkRate', [267,207,60,30,20], 'ModelParams', [.81,.55,1.01,1.19,.76,.93,.28,.25,98.27,243.69], 'EventDrivenChangeFcn', @projects.vision_research.VisionResearchParameterAdjustFcn, 'FitnessFcn', @lib.MaxLik, 'NumberSubjects', 1, 'InitializeRandomWalkParameters', @projects.vision_research.VRcreateRandomWalkParams)

settings = lib.rwexperimentset('ExperimentName', 'henderson_up', 'NumberTrials', 10, 'NumberStates', [38, 10, 10, 10, 10], 'WalkRate', [267,207,60,30,20], 'ModelParams', [1,1,1,1,1], 'EventDrivenChangeFcn', @HendersonAdjustFcn, 'FitnessFcn', @lib.hendersonMaxLik, 'NumberSubjects', 1, 'InitializeRandomWalkParameters', @projects.henderson.HendersonCreateRandomWalkParams, 'plotFcn', @vis.henderson_mean)

ucm(settings)
```




