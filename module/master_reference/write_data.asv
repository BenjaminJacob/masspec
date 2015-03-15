%Teilmodul (Rausschreiben) des Programms Masspec aufruf durch Modul master_ref
%Author: Benjamin Jacob (Benjamin.Jacob@uni-Oldenburg.de)

%Aufgabe:
% 1) Integrieren der Eingabematrix(data2) in eine Kopie der Masterdatei, Proben sind in der Zeile des Masters der ihnen Aufgrund ihrer Masse und
% Resolution nach der Berechnung im Hauptdokument (master_ref) am ehesten zuzuordnen ist.
% 2) Aktuallisieren der Datei in Bezug auf Funde und Massenmittelwert aller
% bisher mit einem Masterelement(Summenformel) assoziierten Proben
% 3) Ergänzen einer zweiten Tabelle, die Informationen für alle Probenelemebte der ersten Tabelle enthält in Bezug auf:
% - potenzielle Masterkandidaten
% - jeweiliger Overlay mit diesen
% - relative Wahrscheinlichkeit der Auswahl

%Eingabeargumente:
%data2 - Die Matrix der Zuordnungen 
%p_num - numerische Informationen für sheet 2 (Overlay, relative Wahrscheinlichkeiten)
%p_txt - textliche Informationen für sheet 2 (Summenformel der Masterkandidaten)
%dateiname - name der Ausgabe datei
%suffix - Suffix für den Namen, der die Sicherheit der Zuoordnungen Klassifiziert(assigend,uncertain,obsolete)
%master_data - numerische Informationen des Masterdatensatzes (Masse Intensität Resolution)
%wndw - angabe des Aktuellen Fensters aus der Liste von Bearbeitungsdateien
%l_wndw - Anzahl an Dateien im Fenster
%ids - die ids der Proben zur Makierung der Spalten in der ihre Elemente stehen (inform der Intensität)
%l_pinfo -
%col1 - Die erste Spalte ab der die Zuordnungsmatrix(data2) im sheet1 der
%Ausgabedatei integriert wird.

%Ausgabargumente:
%Zeile - die letzte nicht leere Zeile des 2 sheets der Ausgabe Datei, nach %der kommende Einträge zur wahrscheinlichkeit des Probenmatch beginnen


function [l_pinfo psheet]=write_data(data2,p_num,p_txt,dateiname,suffix,master_data,wndw,l_wndw,ids,l_pinfo,col1,send,psheet)
l=length(master_data)+1;
%% Aktualisieren von Anzahl Funde und Mittelwert
if wndw==1;xlswrite([dateiname suffix '.xlsx'],{'delta C12 C13','#C12 = predict'},1,'G1');end

%Alten (Teil-)Mittelwert auslesen
old_n_mean=xlsread([dateiname suffix '.xlsx'],1,['D2:F' num2str(l)]);

if size(old_n_mean,2)>1
old_n_mean=old_n_mean(:,2:end);
else    old_n_mean=nan(size(old_n_mean,1),2);
end
escript=cell(l,2);

%mittlere masse und gezählte funde schreiben
[val ind_data2 ind_master]=intersect(data2(:,1),master_data(:,1));
clear val ind_data2

old_n_mean(ind_master(isnan(old_n_mean(ind_master,2))),:)=0;
%keyboard
old_n_mean(ind_master,1)=(old_n_mean(ind_master,1).*old_n_mean(ind_master,2)+data2(:,2).*data2(:,3))./(data2(:,3)+old_n_mean(ind_master,2));
old_n_mean(ind_master,2)=old_n_mean(ind_master,2)+data2(:,3);
escript(2:end,:)=num2cell(old_n_mean);    
clear old_n_mean

escript(1,:)={'mean_mass' 'nr matches'};
[stat msg]=xlswrite([dateiname suffix '.xlsx'],escript,1,['E1:F' num2str(l)]);
if ~stat;
disp('failed writing because:')
    msg
    keyboard;
end
%% Hinzufügen der Funde des Probenfensters
l=ind_master(end);
escript=cell(l+1,l_wndw);
escript(1,:)=ids;
escript(1+ind_master,:)=num2cell(data2(:,4:end));
clear data2

%Spalten Identifikation vn oben Links nach unten rechts
r_ol=[col2excellchar(col1) '1'];
%r_ur=[col2excellchar(send) num2str(l)];
r_ur=[col2excellchar(send) num2str(l+1)];
[stat msg]=xlswrite([dateiname suffix '.xlsx'],escript,1,[r_ol ':' r_ur]);
if ~stat;
    disp('schreibvorgang gescheitert')
    msg
   
    disp('veruche succesives schreiben von Teilstücken')
    
    maxfields=1e6;
    maxrows=floor(maxfields/(send-col1+1));
    nsect=ceil((l+1)/maxrows);
    
    %try to write in parts
    

     for sect=1:nsect
         row0=1+maxrows*(sect-1);         
         row1=row0+maxrows-1;
     
         
         if (sect==nsect);row1=l+1;end 
         
     
         r_ol=[col2excellchar(col1) num2str(row0)];
        r_ur=[col2excellchar(send) num2str(row1)];
        [stat msg]=xlswrite([dateiname suffix '.xlsx'],escript(row0:row1,:),1,[r_ol ':' r_ur]);
         
         if ~stat;
    disp('schreibvorgang gescheitert')
    msg
    keyboard;
         end
     end
end
clear escript
%% Hinzufügen der Wahrscheinlichkeits infos der proben aus dem Fenster in sheet2
max_n_master=max((sum((~isnan(p_num(:,5:end))),2))/4);
p_header=cell(1,5+5*max_n_master);
p_header(1:5)={'intensity' 'probe' 'mass' 'std' 'p_relativ'};
for i=1:max_n_master
    nr=num2str(i);
    p_header(6+(i-1)*5:6+(i-1)*5+4)={['master' nr ': formula'], 'overlay' 'mass' 'intensity' 'std'};
end

probability_info=cell(1+size(p_num,1),length(p_header));
probability_info(1,1:length(p_header))=p_header;
probability_info(2:end,[1 3:5])=num2cell(p_num(:,1:4));   %Proben Infos und P_relativ
probability_info(2:end,2)=p_txt(:,1);           %Probe
p_txt=p_txt(:,1:1+max_n_master);
p_num=p_num(:,1:4+4*max_n_master);
probability_info(2:end,6:5:length(p_header))=p_txt(:,2:end);%Formel
clear p_txt
probability_info(2:end,7:5:length(p_header))=num2cell(p_num(:,5:4:end));%Overlay
probability_info(2:end,8:5:length(p_header))=num2cell(p_num(:,6:4:end));%Intensity
probability_info(2:end,9:5:length(p_header))=num2cell(p_num(:,7:4:end));%mass
probability_info(2:end,10:5:length(p_header))=num2cell(p_num(:,8:4:end));%std
clear p_num 
b=size(probability_info,2);
if wndw==1
zeilen=size(probability_info,1);
r_ur=[col2excellchar(b) num2str(zeilen)];
else
zeilen=size(probability_info,1)-1; %Ohne Überschrift: -1 
r_ur=[col2excellchar(b) num2str(zeilen+l_pinfo)];
end
[stat msg]=xlswrite([dateiname suffix '.xlsx'],probability_info(2-(wndw==1):end,:),psheet,['A' num2str(l_pinfo+1) ':' r_ur]);
if ~stat;
   disp('failed writing overflow')
   msg
   disp('therefore adding new sheet')
    l_pinfo=1;    
    psheet=psheet+1;
    zeilen=size(probability_info,1);
    r_ur=[col2excellchar(b) num2str(zeilen+l_pinfo)];
    [stat msg]=xlswrite([dateiname suffix '.xlsx'],probability_info(1:end,:),psheet,['A' num2str(l_pinfo+1) ':' r_ur]);
        
end
l_pinfo=l_pinfo+zeilen;
end