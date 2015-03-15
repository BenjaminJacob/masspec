% Menustruktur zum Programm masspec_gui (erstellt mit Guide)
% Steureng des Programms zur Zuordnung Massenspektrometischer Daten
% Author: Benjamin Jacob
% Datum: 30.03.2011
function varargout = masspec_GUI(varargin)

addpath(genpath(pwd))

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @masspec_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @masspec_GUI_OutputFcn, ...
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
%% Weitere intitals für die callbacks

%%
% --- Executes just before masspec_GUI is made visible.
function masspec_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to masspec_GUI (see VARARGIN)

% Choose default command line output for masspec_GUI
handles.output = hObject;



%define workdir
handles.workdir=pwd;
%Voreinstellen der Verzeichnisse
if nargin==11
    
    handles.sample_dir=varargin{1};
    handles.assigned_dir=varargin{2};
    handles.masterlist=varargin{3};
    s=varargin{4};
    if s(1)=='w' %with intensity
        handles.overlap=2;
    elseif s(1)=='n' %no intensity
        handles.overlap=1;
    else  %own function
        handles.overlap=3;
    end
    handles.tol=varargin{5};
    handles.psave=varargin{6};
    handles.pcrit=varargin{7};
    handles.wndw_sze=varargin{8};
    
    
else
    handles.sample_dir=[];
    handles.assigned_dir=[];
end

% Update handles structure
guidata(hObject, handles);
if nargin==11
    cd('module')
    main(hObject,eventdata, handles);
end



% --- Outputs from this function are returned to the command line.
function varargout = masspec_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in samplebox.
function samplebox_Callback(hObject, eventdata, handles)
% hObject    handle to samplebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns samplebox contents as
% cell array
choice={get(hObject,'Value')};% returns selected item from listbox1
choice=choice{:};
contents = get(hObject,'String');
handles.probe=contents(choice);
%----
[handles.data handles.id_name]=xlsread([handles.sample_dir '\' contents{choice}]);
handles.ids=unique(handles.id_name(2:end,1)); %alle (unterschiedlichen) vorkommenen Bezeichner (ids)
handles.id_name=handles.id_name(2:end,:);
dm=diff(unique(handles.data(:,1)));%gleicher peak in gleiche rprobe nixch möglicn -> alernative formeln rauskicken
n=length(dm)+1;
dmin=min(dm);
set(handles.peaksdata,'String',num2str(n))
set(handles.mindmdata,'String',num2str(dmin))
set(handles.popupmenu1,'String',handles.ids,...
    'Value',1)
cd(handles.workdir)
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function samplebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samplebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in samplebutton.
function samplebutton_Callback(hObject, eventdata, handles)
% hObject    handle to samplebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_dir=uigetdir('','Bitte Verzeichnis der Proben wählen');
cd(data_dir)
dir_struct = [dir([data_dir,'\*.xls*']); dir(['*.ascii'])];
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
%sorted_index(strcmp(sorted_names,'.')|strcmp(sorted_names,'..'))=[];
%sorted_names(strcmp(sorted_names,'.')|strcmp(sorted_names,'..'))=[];
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
handles.sample_dir=data_dir;
cd(handles.workdir)
% Update handles structure
guidata(hObject, handles);
set(handles.text13,'String',[ num2str(length(sorted_names)) ' files'],'Value',1)
set(handles.samplebox,'String',handles.file_names,...
    'Value',1)

% --- Executes on selection change in destinationbox.
function destinationbox_Callback(hObject, eventdata, handles)
% hObject    handle to destinationbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns destinationbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from destinationbox


% --- Executes during object creation, after setting all properties.
function destinationbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destinationbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in destinationbutton.
function destinationbutton_Callback(hObject, eventdata, handles)
% hObject    handle to destinationbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_assigned_dir=uigetdir('','Bitte Zielverzeichnis (anderes als Listenverzeichnis) für prozessierte Daten wählen');
cd(data_assigned_dir)
dir_struct = dir(data_assigned_dir);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
sorted_index(strcmp(sorted_names,'.')|strcmp(sorted_names,'..'))=[];
sorted_names(strcmp(sorted_names,'.')|strcmp(sorted_names,'..'))=[];
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
handles.assigned_dir=data_assigned_dir;
guidata(handles.figure1,handles)
set(handles.destinationbox,'String',handles.file_names,...
    'Value',1)
cd(handles.workdir)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.logfile=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of checkbox1
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in matchbutton.
function matchbutton_Callback(hObject, eventdata, handles)
% hObject    handle to matchbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd('module')
status=dir([handles.sample_dir,'/*.xls*']);
status2=dir([handles.sample_dir,'/*.ascii']);

if isempty(status) && isempty(status2)
    warndlg('Das Probenverzeichnis ist leer, bitte neues Verzeichnis wählen ')
    cd(handles.workdir);
    
elseif isempty(handles.assigned_dir)
    warndlg('Das Zielverrzeichnis ist noch nicht gewählt, bitte Zielverzeichnis wählen ')
    cd(handles.workdir);
    
elseif isempty(handles.masterlist) || ~regexp(handles.masterlist, 'xls')
    warndlg('Das Masterdatei ist nicht gewählt oder keine xls/xlsx datei, bitte neu wählen ')
    cd(handles.workdir);
    
else
    
    %   profile on
    main(hObject,eventdata, handles);
    %   profile viewer
    cd(handles.workdir)
    guidata(handles.figure1,handles)
end

% --- Executes on selection change in masterbox.
function masterbox_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns samplebox contents as
% cell array
% choice={get(hObject,'Value')};% returns selected item from listbox1
% choice=choice{:};
% contents = get(hObject,'String');
handles.probe=handles.masterlist(max(find(handles.masterlist=='\'))+1:end);

%----
[handles.data handles.id_name]=xlsread(handles.masterlist);
handles.ids=unique(handles.id_name(2:end,1)); %alle (unterschiedlichen) vorkommenen Bezeichner (ids)
handles.id_name=handles.id_name(2:end,:);
dm=diff(unique(handles.data(:,1)));%gleicher peak in gleiche rprobe nixch möglicn -> alernative formeln rauskicken
n=length(dm)+1;
dmin=min(dm);
set(handles.peaksdata,'String',num2str(n))
set(handles.mindmdata,'String',num2str(dmin))
set(handles.popupmenu1,'String',handles.ids,...
    'Value',1)
cd(handles.workdir)
% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function masterbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to masterbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


%Prüfe Verweis auf  Masterdatei in Masterpath.opt
if exist('module/masterpath.txt','file')
    mp=fopen('module/masterpath.txt','r');
    master_path=fgetl(mp);
    master_dat=fgetl(mp);
    set(hObject,'String',master_dat,...
        'Value',1)
    handles.masterlist=[master_path master_dat];
    fclose(mp);
    
else
    handles.masterlist=[];
    
end

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


% --- Executes on button press in masterbutton.
function masterbutton_Callback(hObject, eventdata, handles,opts)
% hObject    handle to masterbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[master_dat,master_path,FilterIndex] = uigetfile('*.xlsx','Please choose masterlist in .xlsx format');



guidata(handles.figure1,handles)
set(handles.masterbox,'String',master_dat,...
    'Value',1)

cd(handles.workdir)
handles.masterlist=[master_path master_dat];
% Update handles structure
%datei mit bevorzugtem Masterverzeichnis anlegen
mp=fopen('module/masterpath.txt','w');
fprintf(mp,'%s\n',master_path);
fprintf(mp,'%s',master_dat);
fclose(mp);


guidata(hObject, handles);






% --- Executes when selected object is changed in uipanel8.
function uipanel8_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel8
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = get(handles.uipanel8,'SelectedObject');
s = get(h,'String');
if s(1)=='w' %with intensity
    handles.overlap=2;
elseif s(1)=='n' %no intensity
    handles.overlap=1;
else  %own function
    handles.overlap=3;
end

%handles.overlap=(s(1)=='w')+1;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function uipanel8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%h = get(handles.uipanel8)
%h = get(handles.uipanel8,'SelectedObject')
%s = get(h,'String')
handles.overlap=1;
guidata(hObject, handles);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(hObject,'Value');
list=get(handles.popupmenu1,'String');%get(hObject,'String');
handles.probe=list(val);
match=strmatch(list(val),handles.id_name);
dm=diff(unique(handles.data(match,1)));%gleicher peak in gleiche rprobe nixch möglicn -> alernative formeln rauskicken
n=length(dm)+1;
dmin=min(dm);
set(handles.peaksdata,'String',num2str(n))
set(handles.mindmdata,'String',num2str(dmin))
guidata(hObject, handles);

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotbutton.
function plotbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(2)
x=handles.data(:,1);%(strmatch(handles.probe,handles.id_name(:,1)),1);
y=handles.data(:,3);%(strmatch(handles.probe,handles.id_name(:,1)),2);
[vals unq_ids]=unique(x);
bar(x(unq_ids),y(unq_ids))
title(['Probe:  ' handles.probe],'fontsize',20)
xlabel('m/z ','fontsize',17)
ylabel('I','fontsize',17)






function editpsave_Callback(hObject, eventdata, handles)
% hObject    handle to editpsave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editpsave as text
handles.psave =str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editpsave_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editpsave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
handles.psave=0.9;  %Intialvalue für Wahrscheinlichkeit
set(hObject,'String',num2str(handles.psave))
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Update handles structure
guidata(hObject, handles);



function editpcrit_Callback(hObject, eventdata, handles)
% hObject    handle to editpcrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pcrit =str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of editpcrit as text
%        str2double(get(hObject,'String')) returns contents of editpcrit as a double
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editpcrit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editpcrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
handles.pcrit=0.5;
set(hObject,'String',num2str(handles.pcrit))
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Update handles structure
guidata(hObject, handles);



function edit_preseelection_tolerance_Callback(hObject, eventdata, handles)
% hObject    handle to edit_preseelection_tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_preseelection_tolerance as text
%        str2double(get(hObject,'String')) returns contents of edit_preseelection_tolerance as a double
handles.tol=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_preseelection_tolerance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_preseelection_tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.tol=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes when selected object is changed in uipanel16.
function uipanel16_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel16
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%keyboard
h = get(handles.uipanel16,'SelectedObject');
s = get(h,'String');
handles.format=s(1);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function uipanel16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%guidata(hObject, handles);
%keyboard
%h = get(handles.uipanel16,'SelectedObject');
%s = get(h,'String');
%handles.format=s(1);
%set(hObject,'Value',1);
handles.format='E';
h = get(hObject,'SelectedObject');
set(h,'Value',1);
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function matchbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matchbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function radiobutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over destinationbutton.
function destinationbutton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to destinationbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function samplebutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samplebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over samplebutton.
function samplebutton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to samplebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function destinationbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destinationbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on key press with focus on destinationbutton and no controls selected.
function destinationbutton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to destinationbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function masterbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to masterbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function logo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to logo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
bild=imread('logo.png');
image(bild);
axis off
% Hint: place code in OpeningFcn to populate
