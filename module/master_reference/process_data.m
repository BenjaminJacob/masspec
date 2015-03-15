function [assignment assignment_uncrtn p_asgnd_num p_asgnd_txt...
    p_uncrt_num p_uncrt_txt no_refs]=process_data(master_data,data,assignment,assignment_uncrtn,probe_size,p_asgnd_num,p_asgnd_txt,row_p,p_uncrt_num,p_uncrt_txt,row_uncrtn,no_refs)

% process data part of masspec is a subrotuine of master_ref
%
% it prepares the assignments for the output into the excele files
% replacing zeros by nans to gete empty cells instead of zeros in excels.
% It replaces the internal identification of sample numbering by their
% Intensitys and adds mean values for an assignment group of one master


[mass,intens,~]=set_column_index;


    %if master used
    if master_data(1)
        assignment(assignment(:,1)==0,:)=[]; %delete empty rows
        assignment(assignment==0)=nan;       %replace zeros for empty cells in excel
        
        
        l_assignment=size(assignment,1);
        masses=nan(l_assignment,probe_size);
        %calculate average masses
        masses(~isnan(assignment(:,4:end)))= data(assignment([false(l_assignment,3) ~isnan(assignment(:,4:end))]),mass);
        assignment(:,2:3)=[nanmean(masses,2) sum(masses>0,2)];%mean mass and number of matches
        assignment([false(l_assignment,3) ~isnan(assignment(:,4:end))])=... %replace enumaration index by intensity
            data(assignment([false(l_assignment,3) ~isnan(assignment(:,4:end))]),intens);
        
        %repeat steps for uncrtn list
        assignment_uncrtn(assignment_uncrtn(:,1)==0,:)=[];
        assignment_uncrtn(assignment_uncrtn==0)=nan;
        l_assignment_uncrtn=size(assignment_uncrtn,1);
        masses=nan(l_assignment_uncrtn,probe_size);
        masses(~isnan(assignment_uncrtn(:,4:end)))= data(assignment_uncrtn([false(l_assignment_uncrtn,3) ~isnan(assignment_uncrtn(:,4:end))]),mass);
        assignment_uncrtn(:,2:3)=[nanmean(masses,2) sum(masses>0,2)];
        assignment_uncrtn([false(l_assignment_uncrtn,3) ~isnan(assignment_uncrtn(:,4:end))])=...
            data(assignment_uncrtn([false(l_assignment_uncrtn,3) ~isnan(assignment_uncrtn(:,4:end))]),intens);
                
        %reduce to necessery size
        p_asgnd_num(row_p:end,:)=[];
        p_asgnd_txt(row_p:end,:)=[];
        p_asgnd_num(~p_asgnd_num)=nan;
        p_asgnd_num(:,1)=data(p_asgnd_num(:,1),intens);%replace enumaration index by intensity
                
        
        if row_uncrtn
            p_uncrt_num(row_uncrtn:end,:)=[];
            p_uncrt_txt(row_uncrtn:end,:)=[];
            p_uncrt_num(~p_uncrt_num)=nan;
            p_uncrt_num(:,1)=data(p_uncrt_num(:,1),intens);;%replace enumaration index by intensity
        end
    end
    
    no_refs(~no_refs)=[];