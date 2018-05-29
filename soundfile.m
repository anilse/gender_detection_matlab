function varargout = soundfile(varargin)
%soundfile MATLAB code file for soundfile.fig
%      soundfile, by itself, creates a new soundfile or raises the existing
%      singleton*.
%
%      H = soundfile returns the handle to a new soundfile or the handle to
%      the existing singleton*.
%
%      soundfile('Property','Value',...) creates a new soundfile using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to soundfile_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      soundfile('CALLBACK') and soundfile('CALLBACK',hObject,...) call the
%      local function named CALLBACK in soundfile.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help soundfile

% Last Modified by GUIDE v2.5 29-May-2018 13:20:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @soundfile_OpeningFcn, ...
                   'gui_OutputFcn',  @soundfile_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before soundfile is made visible.
function soundfile_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for soundfile
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes soundfile wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = soundfile_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global x fs ms20 y filename;
varargout{1} = handles.output;
[file_name file_path] = uigetfile ({'*.wav'});
    if file_path ~= 0
        filename = [file_path,file_name];                
    end
[y, fs] = audioread(filename);
soundsc(y,fs);
cla;
axes(handles.axes1);
ms20 = fs/50;
t = (0:length(y)-1)/fs;
plot(t,y);
title('Waveform');
xlabel('Time (s)');
ylabel('Amplitude');
x = y;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global x fs ms20 ms2 r;
axes(handles.axes2);
cla;
%calculate autocorrelation
r = xcorr(x, ms20, 'coeff');
%plot autocorrelation
d = 1000*(-ms20:ms20)/fs;
plot(d, r);
title('Autocorrelation');
xlabel('Delay (ms)');
ylabel('Correlation coeff.');
ms2 = fs/500; %maximum speech Fx at 500Hz
ms20 = fs/50; %maximum speech Fx at 50Hz
%just look at region corresponding to positive delays
r = r(ms20 + 1 : end);
[rmax, tx] = max(r(ms2:end));
Fx = fs/(ms2+tx-1);

if Fx <= 175 && Fx >= 75
    set(handles.gender,'String', 'Male');
    set(handles.Fx,'String', num2str(round(Fx)));
    guidata(hObject, handles);
elseif Fx > 175 && Fx <= 260
    set(handles.gender,'String', 'Female');
    set(handles.Fx,'String', num2str(round(Fx)));
    guidata(hObject, handles);
else
    set(handles.gender,'String', 'Could not recognize. Try speaking slowly.');
    set(handles.Fx,'String', num2str(Fx));
    guidata(hObject, handles);
end
