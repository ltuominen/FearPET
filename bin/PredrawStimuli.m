function TrialStruct = PredrawStimuli( TrialStruct )
% Function to setup presentation of experiment. This includes opening the
% first window, and loading the images (called textures).
%
% NOTE: Assumes a stimuli folder within the experiment folder that contains
% all of the images. 

%% Setup screen parameters.
% If no specified screen parameters, get current screen resolution and set 
% as default.
%screens = Screen('Screens');
%CurrentScreen = max(screens)
%TrialStruct.xRes = CurrentScreen.width;
%TrialStruct.yRes = CurrentScreen.height;
%TrialStruct.Rect = [0 0 TrialStruct.xRes TrialStruct.yRes]; %% for debugging [0 0 640 480] / full screen: [0 0 TrialStruct.xRes TrialStruct.yRes]
%TrialStruct.Clrdepth = CurrentScreen.pixelSize;
%TrialStruct.Black = BlackIndex(CurrentScreen);
%TrialStruct.White = WhiteIndex(CurrentScreen);
%TrialStruct.Gray = TrialStruct.White/2

% Get the screen numbers
screens = Screen('Screens');
screenNumber = max(screens);
TrialStruct.Black = BlackIndex(screenNumber);
TrialStruct.White = WhiteIndex(screenNumber);
TrialStructure.Grey = TrialStruct.White/ 2;

[TrialStruct.MainWindow, TrialStruct.Rect] = PsychImaging('OpenWindow', screenNumber, TrialStructure.Grey);

Screen('BlendFunction', TrialStruct.MainWindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[TrialStruct.xRes, TrialStruct.yRes] = Screen('WindowSize', TrialStruct.MainWindow);

%[xCenter, yCenter] = RectCenter(TrialStruct.windowRect);

%% Open initial window. 
%TrialStruct.MainWindow = Screen('OpenWindow',0, ...
%                                 TrialStruct.Black, ...
%                                 TrialStruct.Rect, ...
%                                 TrialStruct.Clrdepth);
                                                                    
%% Locate stimuli in folder. 
StimPath = fullfile( pwd, 'stims_temp' ); 
StimStruct = dir([StimPath filesep '*.jpg']);
Stimuli = {StimStruct.name};

%% Predraw Windows
for n = 1:numel(Stimuli)
    StimPath = fullfile( pwd, 'stims_temp', char(Stimuli(n)) ); 
    % Load stimuli.
    Image = imread(StimPath, 'jpg'); 
    % Rescale stimuli as needed.
    if max(size(Image)) > max(TrialStruct.Rect)
       scaleX = TrialStruct.xRes / size(Image,2);
       scaleY = TrialStruct.yRes / size(Image,1);
       Image = imresize(Image,min([scaleX scaleY]));    
    end
    
    if max(size(Image)) < max(TrialStruct.Rect)
       scaleX = TrialStruct.xRes / size(Image,2);
       scaleY = TrialStruct.yRes / size(Image,1);
       Image = imresize(Image,max([scaleX scaleY]));    
    end
    
    % Assign pointers to stimuli.
    Fieldname = Stimuli{n}( 1:end-4 );
    TrialStruct.Stim.(Fieldname).Texture = Screen('MakeTexture', ...
                                                    TrialStruct.MainWindow, ...
                                                    Image ); 
    
                                                                                  
end  

end