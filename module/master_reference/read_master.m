function [master_data master_formulas s1 nmaster]=read_master(handles,hw)
%% Modul: Read Master Data
%
%input 
%handle structure
%hw: identifier of prgoressbar
%
%Output:
% master_data: numerical data of master: Mass Intensity resolution
% master_formulas: molecular formulas as string
% s1: the last written column in the master document
%     -indicates where to append the data  

disp('reading  master-Excel files')
cont{3}='reading master-Excel files';
waitbar(0,hw,cont);
[master_data master_formulas]=xlsread(handles.masterlist);
if ~isempty(master_data)
    master_formulas=master_formulas(2:end,2);
    [~, s1]=size(master_data);%Letzte belegete spalte im master hinter der neue Proben angeordnet werden
    master_data=master_data(:,[1 3 4]);
    master_formulas(length(master_formulas)+((length(master_data)-length(master_formulas))),:)={''};%gleichlang wie numerische daten
    nmaster=5;%Wie viele Master maximal je Probe rausschreiben
else %Use No Master
    s1=4;
    master_data=0;
    nmaster=0;
end