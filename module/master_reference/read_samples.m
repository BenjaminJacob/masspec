%Teilmodul (Einlesen) des Programms Masspec
%Author: Benjamin Jacob (Benjamin.Jacob@uni-Oldenburg.de)

%Aufgabe:
%1) Extrahiert numerische und textliche Daten aus den jeweiligen Dateien (im Format xls,xlsx und ascii)
% eines Dateifensters(Ausschnit einer Liste von Dateien).
%2) Fasst numerische sowie textliche Daten getrennt für die Rückgabe in
%Matrizen für das Hauptprogramm zusammen.
%3) Akutallisier informationen zu den Daten.

%Eingabeargumente:
% filecell - Liste der Dateien
% wndw - Nummer des Fensters innerhalb des filecell
% wndw_sze - Anzahl der Dateien des aktuellen Fensters
% handles - Informationen über die Ordnerstruktur der Dateien
% shift - verschiebung der Spalten beim Rausschreiben

%Ausgabargumente
% data - die Zusammengefassten numerischen Daten aus den Files (Masse Intensität Resolution)
%Folgende argumentiert sind sortiert nach der Masse der Proben:
% ids - die  Zusammengefassten Proben ids aus den textlichen daten der Files
% dest_col   Die Spalte der Bearbeitunsmatrix (master_ref) assoziert mit einer id

%probe_size - Anzahl an verschiedenen ids (für Dimensions und Positionsberechnungen)
%wndw_size  - Die Anzahl an verschiedenen Proben (aktuallisiert Gegenüber der Eingabe)
%no_ref_start - Die Spaltenverschiebung fürs Rausschreiben aus der sich
%ergibt ab Welcher Spalte in der Ausgabedatei die IDs der Proben im
%aktuellen
%Fenster beginnen


function [data dest_col probe_size id_range col_shift]=getdata(filecell,wndw,wndw_sze,handles,hw,col_shift,cont,probe_size)
%Kombination von Exceldateien (jeweils eine Probe) zu einem
cont{3}='Combine data and sort by mass';
waitbar(0,hw,cont);% disp('Kombiniere Exceldateien, sortiert nach Massen')

wndw_sze_max=min(wndw_sze,length(filecell)-(wndw-1)*wndw_sze);
files=filecell((wndw-1)*wndw_sze+(1:min(wndw_sze_max,length(filecell))));
pos=strfind(files{1},'.');
pos=pos(end);


['reading data from file: ' num2str(files{1})]
fprintf(handles.logid,['reading data from file: ' num2str(files{1}) '\n']);
if sum(strcmp(files{1}(pos+1:end),{'xls','xlsx'}))
    data=xlsread([handles.sample_dir '\' files{1}]);
    textdata(1:length(data))={files{1}(1:pos-1)};
elseif strcmp(files{1}(pos+1:end),{'ascii'})
    [data textdata]=asciiread([handles.sample_dir '\' files{1}]);
end

for file=files(2:end)
    ['reading data from file: ' num2str(file{:})]
    fprintf(handles.logid,['reading data from file: ' num2str(file{:}) '\n']);
    pos=strfind(file{:},'.');
    pos=pos(end);
    %Exceldateien
    if sum(strcmp(file{1}(pos+1:end),{'xls','xlsx'}))
        data_temp=xlsread([handles.sample_dir '\' file{:}]);
        textdata_temp(1:length(data_temp))={file{:}(1:pos-1)};
    elseif strcmp(file{1}(pos+1:end),{'ascii'})
        [data_temp textdata_temp]=asciiread([handles.sample_dir '\' file{:}]);
    end
    data(end+(1:length(data_temp)),:)=data_temp;     %neue daten anhaengen
    textdata(end+(1:length(data_temp)))=textdata_temp(1:length(data_temp));
end


%% check for dublicates
% if length(data)~=length(unique(data,'rows'))
%     
%     [unq_data i_unq]=unique(data,'rows','first');
%     [unq_data2 i_unq2]=unique(data,'rows','last');
%     t1=textdata(i_unq(i_unq~=i_unq2));
%     t2=textdata(i_unq2(i_unq~=i_unq2));
%     
%     if  ~strcmp(t1(1),t2(2))
%         errordlg(['files:' t1(1) t2(1) 'conatin same data.' 'canceling process'])
%         error('canceling process because different named input files contain the same data')        
%         fprintf(handles.logid,['files:' t1(1) t2(1) 'conatin same data.' 'canceling process \n']);
%     end
% end

%all rows have to be unique
% [data index]=unique(data,'rows');
% ids=textdata(index);

%different samples can contain partly same content
[data isorted]=sortrows(data,1);
ids=textdata(isorted);





%Spaltenzuweisung für Ausgabedatei aus id_range bestimmen
id_range=unique(ids); %% Die verschiedenen Werte die die Ids haben können
col_shift=probe_size+col_shift;%calculate shift in output-colums in excel by summung up # of previous written data

dest_col=zeros(length(ids),1);
for i=1:length(id_range)
    dest_col(strcmp(ids,id_range(i)))=3+i;
end


probe_size=length(id_range); %Anzahl verschiedener eingelesener Proben