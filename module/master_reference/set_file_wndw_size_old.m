%get List of Samples
filecell=struct2cell([dir([handles.proben '/' '*.xls*']); dir([handles.proben '/' '*.ascii*'])]);
filecell=filecell(1,:);
ndata=length(filecell);

sprintf('there are %i samples',ndata)

%Groeße Bearbeitungsfenster (wieviele excelfiles gleichzeitig im speicher)
disp('chose windwowsize of simultanious processed files (memory)')



if ~isfield(handles,'wndw_sze')
wndw_sze=str2double(inputdlg('chose windwowsize of simultanious processed files (memory)'));%Fensterbreite
else
wndw_sze=handles.wndw_sze;    
end
tic
%abbruch
if isempty(wndw_sze)
    disp('task cancelled')
    cd(workdir)
    close(hw)
    return
end

wndw_sze=min(wndw_sze,length(filecell));
wndws=ceil(length(filecell)/wndw_sze);
col_shift=0;                            %Spalten-Verschiebung durch Fenster für Ausgabe

fprintf(handles.logid,'Process %i sample files in %i windows of %i files at once \n',ndata,wndws,wndw_sze);
