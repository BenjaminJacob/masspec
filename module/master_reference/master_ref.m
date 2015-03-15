function [master_masses col0 handles]=master_ref(hObject,eventdata, handles,pfun)
%% Master_ref -  modul of Masspec
% 
% Trys to Assign Peaks of a sample Pool to a reference master peak from the
% master list based on a score system with threshholds.
%
% Assignments are seperated along two threshholds: 
% > p_certain (higher degree security) results are stored in excel document: master_add_assigned
% > p_uncertain (lower degree of security): results are stored in excel document: master_add_uncertain_assigned
%
% Input: 
% handles - the handles strucutre - locating all important directories an
%           settings (e.g the overlap score and the threshholds
%
% Output: 
% master_masses - list of sorted masses of the master_list (needed to indentify cluster insert positions by cluster_include)
% cols1 - the column where to beginn appending the Intensitys (-serve as identification) of assigned
%         samples peaks
% handles - the updatet handles strucrute
%
% Outputfiles:
%
% master_add_assigned.xlsx - first sheet: contains assignments succeding
%                            the upper score limit rho_upper_lim
%                          - sheet2 further assignment informations, as
%                            alternative masters overlap scores with them
%                            Assignments in this list are considered to be 
%                            a secure match
%
% master_add_uncertain.xlsx - anlagous to master_add_assigned.xlsx but for
%                             assignments scoring betwenn rho_upper_lim 
%                             and rho_lower_lim 
%                            Assignments in this list are considered to be
%                            unsecure matches and requier checking by hand
%
% no_refs.dat              - is a list of peaks containing those which
%                            failed a score of rho_lower_lim and are 
%                            considered to have no matches a long the
%                            master list. This list serves the Peaks for 
%                            cluster_build to build the clusters 

fprintf(handles.logid,'starting master_ref \n');% write to log files

%Progressbar
if handles.gui==1
    cont={'Step 1 / 3 Reference' '\newline' 'start make reference' '\newline'};
    hw = waitbar(0,cont);
end
% which column conatins mass,intensity,resolutuion
[mass,intens,res]=set_column_index; 

%legnth pointer to lasst nonzero field of vector
l_pcrtn=0;          %Letzte belegte Zeile sicher Zuordnungsmatrix
l_pncrtn=0;         %Letzte belegte Zeile unsichere Zuordnungsmatrix


%how many files at once ? -> seperate in wndws
set_file_wndw_size


%Messurre Progress
initial_progress_measure  %set initial values for progress measure

% marker for alternatives
cm_id=fopen([handles.assigned_dir '\color_marks.dat'],'w');

%% Overall wndws of data find matches to master
%Progressbar
if handles.gui==1
    cont{3}='initialise output files';
    waitbar(0,hw,cont);
end

%Initialdatei erstellen - für weiteres hinzufügen der Proben
filename='master_add';
system(['copy ' '"' handles.masterlist '"' ' ' '"' [handles.assigned_dir '\' filename '_assigned.xlsx'] '"']);
system(['copy ' '"' handles.masterlist '"' ' ' '"' [handles.assigned_dir '\' filename '_uncertain.xlsx'] '"']);
h_noref=fopen([handles.assigned_dir '\norefs.dat'],'a');                  %nicht mit mastern referenierbare

fprintf(handles.logid,'Outputfiles for different score levels and not referenced peaks created as \n %s \n %s \n %s \n',...
    [handles.assigned_dir '\' filename '_assigned.xlsx'],[handles.assigned_dir '\' filename '_uncertain.xlsx'],[handles.assigned_dir '\norefs.dat']);

%read master data
[master_data master_formulas col0 nmaster]=read_master(handles,hw);
fprintf(handles.logid,'read master data - succesfull \n');


%Excel Output file columns: 
%1. m/z	2. Formel	3. I 4. Res.  5. mean_mass	6. nr matches	7. delta C12 C13	 
%8. #C12 = predict  9. Intensities sample 1   10. Intensities sample 2 11. ...
col0=col0+1;% col last used column in master -> next column as beginning for current assignent set
col0=col0+4*(col0==5); %if starting from an initial master (containing no assignments)
                       %shift for range of columns (5 to 8)
col1=col0;             % Begining column for different asignment windows
probe_size=0;          % how many samplefiles in courent window -> shifting col1

%sheet nr of further score information
psheet=2;
psheet_uncrtn=2;


initial_progress_measure

for wndw=1:wndws
    
    fprintf(handles.logid,'start reference wndw %i \n',wndw);
    if handles.gui==1 
        cont{3}=['start referencing with window ' num2str(wndw) '/' num2str(ceil(length(filecell)/wndw_sze))];
        waitbar(0,hw,cont);
    end
    %Matrix row indices -----------------------------------------
    %assignment data (Excel sheet 1)
    row=0;              %high overlap assigned
    row_uncrtn=0;       %uncertain overlap assigned
    
    %Overlap details (Excel sheet 2)
    row_p=1;            %high overlap assigned
    row_p_uncrtn=1;     %obsolete assigned
    %-----------------------------------------------------
    
    %merge sample data of current window sorted by mass
    [data dest_col probe_size id_range col_shift]=read_samples(filecell,wndw,wndw_sze,handles,hw,col_shift,cont,probe_size);
    
    %memory Management - Matritzen/Cells allocating (later on dynamical growth) -----------------------------------------
    [l_data,assignments,l_assignments,assignments_uncrtn,l_assignments_uncrtn...
        p_asgnd_num,p_asgnd_txt,l_p,p_uncrt_num,p_uncrt_txt,l_uncrt,no_refs,i_no_refs block p_block p_cellblock l_block l_p_block]=intitial_memory_allocation(data,probe_size,nmaster);
    
    %Progress guessing - mean peaks per Excelfile
    mnpknmbr=((l_data/probe_size)+mnpknmbr*(wndw-1))/wndw;
    
    
    %% III assign peaks - Loop over all lodead Peakdata of current window
    
    %loop over all peaks
    for i=1:length(data)
        
        %progressbar and time estimation
        [tt ti itot0 verbrauch]=show_progress(i,l_data,tt,mnpknmbr,verbrauch,ti,itot0,hw,wndw,wndws,ndata);
        
        %CALCULATING OVERLAP WITH MASTERS WITHIN TOLERANCE INTERVALL----------------------------------------------------------------------------------
        
        %Moments sample
        %i_data=data(i,intens);
        mu_data=data(i,mass);
        sig_data=1/sqrt(log(4))*mu_data/data(i,res);
        
        
        %preselection in tolerance interval
        match=find(abs(master_data(:,mass)-mu_data)<=max(handles.tol*sig_data,1e-3));
       
        %no matches -> no_refs -> cluster later
        if isempty(match)
            no_refs(i_no_refs)=i;
            i_no_refs=i_no_refs+1;
            
            %When matches then Calculate Overlaps
        else
           
            %Moments Sample
            i_data=data(i,intens);
            %mu_data=data(i,mass);
            %sig_data=1/sqrt(log(4))*(data(i,mass)./data(i,res));
            
            %Moments Master
            i_master=master_data(match,intens);
            mu_master=master_data(match,mass);
            sig_master=1/sqrt(log(4))*(master_data(match,mass)./master_data(match,res));
            
            %Overlap -> Select best
            p=pfun(i_data,i_master,mu_data,mu_master,sig_data,sig_master)';
            
            %reduce to nmaster matches to compare as maximum
            %and sort by decreasing score
            [~, isort]=sort(1-p);
            isort=isort(1:min(nmaster,length(match)));%reduce to nmatch best matches
            match=match(isort);
            i_master=i_master(isort);
            mu_master=mu_master(isort);
            sig_master=sig_master(isort);
            p=p(isort);
            choice=1;
            %----------------------------------------------------------------------------------
            
            %% Auftrennen nach Verschiedenen Wahrscheinlichkeits-Levels
            
            %SICHERE ZUORDNUNG
            if max(p)>=handles.psave
                
                %speichere check: Dynamisch allocieren
                if row +1 > l_assignments
                    assignments(end+(1:l_block),:)=block;
                    l_assignments=l_assignments+l_block;
                end
                
                if row_p+1 > l_p
                    p_asgnd_num(end+(1:l_p_block),:)=p_block;
                    p_asgnd_txt(end+(1:l_p_block),:)=p_cellblock;
                    l_p=size(p_asgnd_num,1);
                end
                
                %Assign data - append new columns
            
                [assignments p_asgnd_num p_asgnd_txt row row_p p_rel no_refs i_no_refs]=assign_data(master_data,i_master,mu_master,sig_master,master_formulas,match,...
                    data,i_data,mu_data,sig_data,i,...
                    assignments,row,dest_col,id_range,p,row_p,choice,p_asgnd_num,p_asgnd_txt,l_p,no_refs,i_no_refs);
                
                
                %mark when alternatives are relevant
                if p_rel < 0.6
                    colnr=col1+dest_col(i)-3-1;
                    fprintf(cm_id,'%f %i %i\n',mu_master(choice(1)),colnr,data(i,intens));
                end
                
                
            elseif max(p) >= handles.pcrit
                
                %speichere check: Dynamisch allocieren
                if row_uncrtn + 1 > l_assignments_uncrtn
                    assignments_uncrtn(end+(1:l_block),:)=block;
                    l_assignments_uncrtn=l_assignments_uncrtn+l_block;
                end
                
                
                if row_p_uncrtn + 1 > l_uncrt
                    p_uncrt_num(end+(1:l_p_block),:)=p_block;
                    p_uncrt_txt(end+(1:l_p_block),:)=p_cellblock;
                    l_uncrt=size(p_uncrt_num,1);
                end
                
                %Assign data - append new columns
                [assignments_uncrtn p_uncrt_num p_uncrt_txt row_uncrtn row_p_uncrtn p_rel no_refs i_no_refs]=assign_data(master_data,i_master,mu_master,sig_master,master_formulas,match,...
                    data,i_data,mu_data,sig_data,i,...
                    assignments_uncrtn,row_uncrtn,dest_col,id_range,p,row_p_uncrtn,choice,p_uncrt_num,p_uncrt_txt,l_uncrt,no_refs,i_no_refs);
                
                %Assign no_refs to cluster later on
            else
                no_refs(i_no_refs)=i;
                i_no_refs=i_no_refs+1;
            end
            
        end
 
    end
    itot0=itot0+i;

    %speicher gewinnen
    clear i block p_block p_cellblock l_block i_form l_uncrt lobs
    clear -regexp l_data i_ match
    
    
    
    %% Process Data - replace internal intex by intensity and avoid zeros in excel sheets
        [assignments assignments_uncrtn p_asgnd_num p_asgnd_txt...
        p_uncrt_num p_uncrt_txt no_refs]=process_data(master_data,data,assignments,assignments_uncrtn,probe_size,p_asgnd_num,p_asgnd_txt,row_p,p_uncrt_num,p_uncrt_txt,row_uncrtn,no_refs);
    
    
    %% Write Data
    
    %Determine interval (first and last colum) where to place sample intensities in outputexcel file
     col_end=col1+probe_size-1;%last outputfile column for current assignment window

    
        [l_pcrtn psheet l_pncrtn psheet_uncrtn]=export_data(handles,data,assignments,assignments_uncrtn,no_refs,p_asgnd_num,p_asgnd_txt,p_uncrt_num,...
    p_uncrt_txt,dest_col,col_shift,master_data,l_pcrtn,psheet,l_pncrtn,psheet_uncrtn,h_noref,wndw,wndws,hw,filename,probe_size,id_range,col1,col_end);  
    
    clear assignments_uncrtn p_uncrt_num p_uncrt_txt row_p_uncrtn
    
    col1=col_end+1;%set beginning output file column for next window
    
    assigned_update(hObject, eventdata, handles);
    cd(handles.workdir);
end

fclose(h_noref);%no_refs schliesen
fclose(cm_id);
close(hw);
master_masses=(master_data(:,1));