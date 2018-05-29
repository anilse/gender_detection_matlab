function varargout = recording(varargin)
%recording MATLAB code file for recording.fig
%      recording, by itself, creates a new recording or raises the existing
%      singleton*.
%
%      H = recording returns the handle to a new recording or the handle to
%      the existing singleton*.
%
%      recording('Property','Value',...) creates a new recording using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to recording_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      recording('CALLBACK') and recording('CALLBACK',hObject,...) call the
%      local function named CALLBACK in recording.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help recording

% Last Modified by GUIDE v2.5 29-May-2018 13:59:39
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @recording_OpeningFcn, ...
                   'gui_OutputFcn',  @recording_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before recording is made visible.
function recording_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to recording (see VARARGIN)

% Choose default command line output for recording
handles.output = hObject;

% Update handles structure
global x;
x = ones(9600,1);
set(hObject, 'toolbar', 'figure');
guidata(hObject, handles);

% UIWAIT makes recording wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = recording_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_plotSignal.
function pushbutton_plotSignal_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plotSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global x fs ms20;
axes(handles.axes1);
cla;
fs = 16000;
ms20 = fs/50; % window length for 20 ms
t = (0:length(x)-1)/fs; % times of sampling instants
plot(t,x);
title('Waveform');
xlabel('Time (s)');
ylabel('Amplitude');
guidata(hObject, handles);


% --- Executes on button press in pushbutton_record.
function pushbutton_record_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global x;
% create the recorder
disp('Record starts!');
msgboxText{1} = 'Recording for 3 seconds...';
r = audiorecorder(16000,16,1);
% record one second of data
recordblocking(r,3);
stop(r);
% get the samples
x = getaudiodata(r);
msgboxText{2} = 'Recording done!';
msgbox(msgboxText,'Signal recording done', 'warn');
disp('Done!');
set(handles.gender,'String','See the estimated gender here');
set(handles.Fx1,'String', 'Fundamental Frequency');
guidata(hObject, handles);


% --- Executes on button press in estimateGender.
function estimateGender_Callback(hObject, eventdata, handles)
% hObject    handle to estimateGender (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global x fs ms20 ms2 r;
axes(handles.axes2);
cla;
if x == 0
    %the first, second and third lines of the message box
    msgboxText{1} = 'You have tried to estimate gender without recording signal';
    msgboxText{2} = 'Try recording a signal using record button';
    %this command actually creates the message box
    msgbox(msgboxText,'Signal recording not done', 'warn');
else
    %calculate autocorrelation
    % coeff method is xcorr(x)/norm(x) with the lag of -ms20 and ms20,
    % gives correlation coefficients
    r = xcorr(x, ms20, 'coeff');
    %plot autocorrelation
    % convert index to milli-seconds
    d = 1000*(-ms20:ms20)/fs;
    plot(d, r);
    title('Autocorrelation');
    xlabel('Delay (ms)');
    ylabel('Correlation coeff.');
    ms2 = fs/500; % speech Fx at 500Hz
    ms20 = fs/50; % speech Fx at 50Hz
    %just look at region corresponding to positive delays for one window.
    r = r(ms20 + 1 :  2*ms20 + 1);
    [rmax, tx] = max(r(ms2:end));
    % Convert index to Hz
    Fx = fs/(ms2+tx-1);
    
    if Fx <= 175 && Fx >= 75
        set(handles.gender,'String', 'Male');
        set(handles.Fx1,'String', num2str(round(Fx)));
        guidata(hObject, handles);
    elseif Fx > 175 && Fx <= 260
        set(handles.gender,'String', 'Female');
        set(handles.Fx1,'String', num2str(round(Fx)));
        guidata(hObject, handles);
    else
        set(handles.gender,'String', 'Could not recognize. Try speaking slowly.');
        set(handles.Fx1,'String', num2str(Fx));
        guidata(hObject, handles);
    end
end


% --- Executes on button press in Play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to Play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global x fs;
if x == 0
    %the first, second and third lines of the message box
    msgboxText{1} = 'You have tried to play without recording signal';
    msgboxText{2} = 'Try recording a signal using record button';
    %this command actually creates the message box
    msgbox(msgboxText,'Signal recording not done', 'warn');
else
    soundsc(x,fs);
    guidata(hObject, handles);
end
