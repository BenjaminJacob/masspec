function main(hObject,eventdata, handles)
%% Masspec Main function
% Masspec is an assignment tool for data gained by high resolution mass
% spectrometry. For details of the principle see the manual and
% pupclication
%
%The Main Programm calls the subroutines:
% master_ref      - references master list peaks with sample lists peaks
%                   based on a Scoresystem
% cluster_build   - Builds clusters of not referenced peaks based
%                   on the same Scoresystem
%
% cluster_include / cluster_include_no_master  - combines the master and
%                                   cluster assignments in one output File
% Gen_mol_form_mc  - assign molecular formulars to the assignments based
%                    on theoretical m/z values
% check_c13        -  searches for C13/C12 Intensity patterns to identify
%                     Isotopes
% alternative_marker - marks relevant alternative assignment of master
%                      references
% masspec_postfilter2 - A Filterprogramm for the Output data

addpath(genpath(cd)) % add all folders with subfolders in this directory.

%create logfile with initial information
handles.logid=fopen([handles.assigned_dir '\masspec.log'],'w');
fprintf(handles.logid,'starting masspec %s %s \n',date,datestr(rem(now,1)));
fprintf(handles.logid,'sample directory: %s \n', handles.sample_dir);
fprintf(handles.logid,'assigned directory: %s \n', handles.assigned_dir);
fprintf(handles.logid,'Masterlist: %s \n', handles.masterlist);

%check weather to start the programm from beginning or to continue a
%corrupted session of ,asspec
if exist([handles.workdir '\reference.mat'],'file')
    load([handles.workdir '\reference.mat']);
elseif exist([handles.workdir '\clusters.mat'],'file')
    load([handles.workdir '\clusters.mat']);
    
else  %normal program start
    %______________________________________________________________________
    %Overlap formula:
    if handles.overlap==2 % 1. with intensity
        ovlp_score=@(i1,i2,mu1,mu2,sig1,sig2)i1*i2.*sqrt(2*pi*(sig1*sig1.*sig2.*sig2)./(sig1*sig1+sig2.*sig2)).*exp(-(mu1-mu2).^2./(2*(sig1*sig1+sig2.*sig2)));
        fprintf(handles.logid,'chosing overlap score with intensity \n');
    elseif handles.overlap==1 % 2. no intensity
        ovlp_score=@(i1,i2,mu1,mu2,sig1,sig2)exp(-(mu1-mu2).^2./(2*(sig1*sig1+sig2.*sig2)));
        fprintf(handles.logid,'chosing overlap score without intensity \n');
    else %own function
        ovlp_score=@(i1,i2,mu1,mu2,sig1,sig2)myfun(i1,i2,mu1,mu2,sig1,sig2);
        fprintf(handles.logid,'chosing user defined overlap score \n');
    end
    %______________________________________________________________________
    
    fprintf(handles.logid,'critical scores rho: assign rho >= %.2f \n uncertain assign rho >= %.2f \n cluster rho < %.2f \n',...
        handles.psave,handles.pcrit,handles.pcrit);
    
    %% PART 1 Try matching sample peaks with peaks from master list
     [master_masses col1 handles]=master_ref(hObject,eventdata, handles,ovlp_score);
     %save([handles.workdir '\reference.mat']);

end


%% PART 2 Cluster sample peaks with no matching master peaks

if ~exist([handles.workdir '\clusters.mat'],'file')
    [storespar cr Cn mean_mass mean_res mean_intens smin smax]=cluster_buildwrite(handles,ovlp_score,col1);
    save([handles.workdir '\clusters.mat']);
    delete([handles.workdir '\reference.mat']);
end

%merge clusters and ouputfile
merge_cluster(handles.assigned_dir,'master_add_assigned.xlsx','clusters.xlsx','master_add_assigned2.xlsx')            
fclose(handles.logid);


