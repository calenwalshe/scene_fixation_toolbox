# Creating random walk models of fixation durations during scene viewing.
A toolbox for creating random walk models of fixation durations during scene viewing.

Here is a quick start method:

```matlab
settings = lib.rwexperimentset('ExperimentName', 'visionresearch', 'humanDataPath',...
  './_data/h_fixdur_exp2.mat', 'NumberTrials', 45, 'NumberStates', [30, 30, 30, 30, 30],...
  'WalkRate', [267,207,60,30,20], 'EventDrivenChangeFcn', @VisionResearchParameterAdjustFcn,...
  'FitnessFcn', @lib.MaxLik, 'NumberSubjects', 1, 'InitializeRandomWalkParameters', @demoCreateRandomWalkParams)


ucm(settings)
```




