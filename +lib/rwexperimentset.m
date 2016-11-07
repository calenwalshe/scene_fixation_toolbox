function settings = rwexperimentset(varargin)
%RWEXPERIMENTSET Create a set of experiment parameters that will be simulated.
%   RWEXPERIMENTSET returns a list of experiment parameters that can be
%   used by the simulation engine to generate predicted fixation duration
%   distributions.
%   
%   OPTIONS = GAOPTIMSET('PARAM',VALUE) creates a structure with the
%   default parameters used for all PARAM not specified, and will use the
%   passed argument VALUE for the specified PARAM.
%
%   This settings file is modelled from the file GAOPTIMSET found in the
%   MATLAB Genetic Algorithms toolbox. All rights for any parts of the code used here belong
%   to Mathworks.
%
%   See also GAOPTIMSET, SIMULATEEXPERIMENT

if (nargin == 0) && (nargout == 0)
    fprintf('ExperimentName:  [ string   ] \n');
    fprintf('      NumberTrials:        [ integer  ]\n');    
    fprintf('      NumberStates:        [ vector ]    | {[28,17,300,259,30,1]}\n');
    fprintf('      WalkRate:            [ vector ]    | {[267,207,60,30,20]}\n');    
    fprintf('      StateChangeFcn:      [ function_handle ]\n');        
    return;
end

%Return settings with default values and return it when called with one output argument
settings =struct('ExperimentName', [], ...
               'NumberTrials', [], ...
               'NumberStates', [], ...
               'WalkRate', [], ...
               'EventDrivenChangeFcn', [], ...
               'NumberSubjects', [], ...               
               'InitializeRandomWalkParameters', [], ...                   
               'FitnessFcn', [],...
               'humanDataPath', [],...
               'VisionResearchParams', []);


Names       = fieldnames(settings);
m           = size(Names,1);
names       = lower(Names);
numberargs  = nargin; 

i = 1;
while i <= numberargs
    arg = varargin{i};
    if ischar(arg)                         % arg is an option name
        break;
    end
    if ~isempty(arg)                      % [] is a valid settings argument
        if ~isa(arg,'struct')
            error('Invalid argument');
        end
        for j = 1:m
            if any(strcmp(fieldnames(arg),Names{j,:}))
                val = arg.(Names{j,:});
            else
                val = [];
            end
            if ~isempty(val)
                if ischar(val)
                    val = deblank(val);
                end
                settings.(Names{j,:}) = val;
            end
        end
    end
    i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(numberargs-i+1,2) ~= 0
    error('Argument value pair missing.');
end
expectval = 0;                          % start expecting a name, not a value
while i <= numberargs
    arg = varargin{i};
    
    if ~expectval
        if ~ischar(arg)
            error('Invalid argument format.');
        end
        
        lowArg = lower(arg);
        j = strmatch(lowArg,names);
        if isempty(j)                       % if no matches
            error('No such parameter');
        elseif length(j) > 1                % if more than one match
            % Check for any exact matches (in case any names are subsets of others)
            k = strmatch(lowArg,names,'exact');
            if length(k) == 1
                j = k;
            else
                allNames = ['(' Names{j(1),:}];
                for k = j(2:length(j))'
                    allNames = [allNames ', ' Names{k,:}];
                end
                allNames = sprintf('%s).', allNames);
                error('Ambiguous parameter name');
            end
        end
        expectval = 1;                      % we expect a value next
        
    else           
        if ischar(arg)
            arg = (deblank(arg));
        end
        settings.(Names{j,:}) = arg;
        expectval = 0;
    end
    i = i + 1;
end

if expectval
    error('Missing parameter');
end