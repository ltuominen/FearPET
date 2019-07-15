function RUNTASK(varargin)
% conditioning paradigm
%
% usage: RUNTASK('TrialsFile')
% parameters:
%       TrialsFile         A .csv-file 
%
%        
% TrialsFiles are .csv-files found in the trialfiles folder. Choose one of
% those. TrialsFile should be written without the .csv extension
% Example: RUNTASK('A')
%
% In case you don't know what you are doing, contact Lauri Tuominen
% at lauri.tuominen@theroyal.ca
% 

addpath([pwd '/bin'])

if nargin ~= 1
    help RUNTASK;
    return;
end

PsychDefaultSetup(2);
KbName('UnifyKeyNames')
clear('Screen');

%% Open dialog box. Query for subject ID
Inputs = inputdlg({'Enter subject ID:'}, 'Input',[1 30]);           
SubjectID = Inputs{1};
%% Generate output filepaths.
timestring = datestr(round(clock),'yyyy_mm_dd_HH_MM_SS');
mkdir(['DATA' filesep SubjectID]);
TrialsFile = ['trialfiles/' varargin{1} '.csv'];
[~,NN,~] = fileparts(TrialsFile);
Output = ['DATA' filesep SubjectID filesep SubjectID '.' NN '.'  timestring '.csv'] ;

%% Setup experiment environment.
TrialStruct = BuildTrialStruct(TrialsFile);

%% Open windoscaw. Predraw stimuli as textures.
try
    TrialStruct = PredrawStimuli(TrialStruct);
    HideCursor();
catch err
    Screen('CloseAll');
    rethrow(err);
end
%Screen('CloseAll')
%% Set up triggers.
clear lj;

try
    lj = Setup_LabJack();
catch err
    Screen('CloseAll'); ShowCursor();
    error('Error in setting up LabJack. Please check equipment.');
end

if lj.isOpen == 0
    Screen('CloseAll'); ShowCursor();
    error('lj.isOpen = 0. Please check labJack.');  
end

Priority(9);
%% Wait to sync with scanner.
% Global start time recorded via this command.
TrialStruct = WaitForScanner( TrialStruct );

%% Go thorough Trials.
nTrials = numel(TrialStruct.Trials)
currentTrial = 1

while currentTrial <= nTrials
    try
        [TrialStruct, flag] = RunTrial(TrialStruct, currentTrial, lj);
        currentTrial = currentTrial + 1;
        
        if flag
            WriteLog_PE(TrialStruct,Output,TrialsFile);
            break;
        end
        
    catch err
        % If there is a problem, write  all current data to file
        % before ending loop.
        Screen('CloseAll');
        WriteLog_PE(TrialStruct,Output,TrialsFile);
        rethrow(err);
    end
end 

if flag
    Screen('CloseAll')
    return
end

% Save data.
save('TestStruct.mat', 'TrialStruct');
WriteLog_PE(TrialStruct,Output,TrialsFile);
WritePar(TrialStruct,Output)

%% Close screens.
Screen('CloseAll');
fclose all;
clc

end

