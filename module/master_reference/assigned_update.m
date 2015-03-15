%Modul: Anzeigenupdate der schon bearbeiteten Dateien
function assigned_update(hObject, eventdata, handles)
dir_struct = dir(handles.assigned_dir);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
sorted_index(strcmp(sorted_names,'.')|strcmp(sorted_names,'..'))=[];
sorted_names(strcmp(sorted_names,'.')|strcmp(sorted_names,'..'))=[];
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
guidata(handles.figure1,handles)
 set(handles.destinationbox,'String',handles.file_names,...
  'Value',1)
cd(handles.workdir)