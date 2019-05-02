function f = objfunHenderson(x)
%display(x)

x = [x(6), x(1), x(2), x(3), x(4), 98.27,243.69];

settings = lib.rwexperimentset('ExperimentName', 'henderson_up', 'NumberTrials',...
    100, 'NumberStates', [38, 10, 10, 10, 10], 'WalkRate', [267 * x(5), 207 * x(5),60 * x(5), 30 * x(5), 20],...
    'ModelParams', x, 'EventDrivenChangeFcn', @HendersonAdjustFcn,...
    'FitnessFcn', @lib.hendersonMaxLik, 'NumberSubjects', 1,...
    'InitializeRandomWalkParameters', @HendersonCreateRandomWalkParams,...
    'plotFcn', @vis.plot_henderson_mean);

f = ucm(settings);

end