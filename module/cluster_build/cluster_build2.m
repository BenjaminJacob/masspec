
function [storespar cr Cn mean_mass mean_res max_intens smin smax]=cluster_build(handles,pfun,col1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Control parameter
Nmebmers=1; %How many members needed to accept a cluster 
%           % if clusters has less than Nmember members its deleted from
%           list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% [storespar cr Cn mean_mass mean_res max_intens smin smax]=cluster_build(handles)
%
%Part of Masspec:
%Builds clusters of peaks which could not be referenced with a master from
%the masterlist, and which are stored in the file no_refs.dat
%
%INPUT:
%handles: handles structure conataining directories etc.
%pfun: anonymus function defining how Overlapscore is calculated
%
%OUTPUT:
%storespar: Sparsematrix, which in each row contains Intensities of peaks grouped to the according cluster
%cr         the ammount of overall rows of storespares (= # clusters)
%Cn         a row vector with the nr of cluster members in the according row of storespar (cluster 1 (cr=1) has Cn(1) members)
%mean_mass  a row vector with the mean mass of cluster members in the according row of storespar
%mean_res   a row vector with the mean resolution of cluster members in the according row of storespar
%max_intens a row vector with the mean Intensity of cluster members in the according row of storespar
%smin       Information about the first sample column in Excel
%smax       Information about the last sample column in Excel
%
%% Part one calculate Global overlap matrix between samples
% Pairwise Overlapscores between all (relevant) peaks arre calculated
%
%% Part two
%Make clusters out of the Overlap Connections between samples I,J:
%n gaps (=differences in row indices > 1) seperate n+1 clusters
%(row I and columns J Identfiy conections [entry I=J are missing because identity is trivial])
% Differences in I, Delta_I > 1 mark breakpoints between a cluster and
% either another cluster or following singleton(s)
%
%  1 2 3 4 5 6 7 8 9 10 11 12    I   J     Delta_I  pos(Delta_I)>1     (Breakpoint position in I as last entry befor delta_I >1)
%1\1 2 3|c1                      1   2        0       3 (Delta_I(3)=4)  Cluster c2 starts at I(pos(1)+1)=I(3+1)=6
%2  \2 3|c1                      1   3        1       6 (Delta_I(6)=3)  and ends at I(pos(2))+1=I(6)+1=8
%3    \3|c1                      2   3        4
%4      \4 s1                    6   7        0         the singletons 4 and 5 lie between the |end of c1|: I(pos(1))+1
%5        \5 s2                  6   8        1         and the |beginning of c2|:I(pos(1)+1):
%6          \6 7 8|c2            7   8        3         [I(pos(1))+1]+1 :[I(pos(1)+1)]-1
%7            \7 8|c2            10  11                 = [I(3)+1]+1 : [I(3+1)]-1
%8              \8|c3            .   .                  =   [2+1]+1  : [6]-1
%9                \9 s3          .   .                  =          4:5
%10                 \10 11 12|c3                       cluster ci contains:
%11                    \11 12|c3                       Elements   I(pos(i-1)+1) : I(pos(i))+1
%12                       \12|c3                       and if I(pos(i-1)+1)-I(pos(i-1))+1 > 2
%                                                      follows a list of singletions given by
%                                                      [I(pos(i-1))+1]+1 :[I(pos(i-1)+1)]-1  (else thus expressions is a empty set)
%
% the overlap matrix is tempotally stored ond disk in three files containin
% 
%% Part 1 Global Overlap Matrix - overlap between "nearby" peaks

fprintf(handles.logid,'starting cluster_build \n');%write to log fike

%read not referenced peaks to cluster
addpath(cd)
cd(handles.assigned_dir);


%load peak data
data=sortrows(load('norefs.dat'),1);


%into which excel column to write the data
dest_col=data(:,4); % column of output excell sheet ascossiated with a sample
off=min(dest_col)-3; % in internal treatment no need for mean values (mean mass/intens/resolution)
dest_col=dest_col-off; %internal reference for columns in local matrix
smin=min(dest_col);%erst spalte
smax=max(dest_col);%letzte spalte
data(:,4)=data(:,4)-smin;
clear dest_col

%indexing
mass=1;
intens=2;
res=3;
sample=4;
%--------

%Output- Sparseinformation
l_data=size(data,1);
I=zeros((l_data),1);%row index
J=I;                %column index
O=I;                %Overlap value

%determine size of Index array before write data to dsik
rsc=whos('mass');
byte_per_entry=(rsc.bytes); %byte size of a double
mem=memory;
ind_store_len=mem.MemAvailableAllArrays/4/3/byte_per_entry;%the 3 large Index entrys may share 1/4 the memory left
ind_store_len=floor(ind_store_len/10^floor(log(ind_store_len)/log(10)))*10^floor(log(ind_store_len+1)/log(10));

I_gaps=zeros(ceil(l_data/10),1);
gap_count=0;
i0=1; %index of first zero for I
i0b=1;%index of first zero for J and O

%Open Files to save Sparsematrix on Disk
hI=fopen('I.bin','wb');
hJ=fopen('J.bin','wb');
hO=fopen('O.bin','wb');


%--------------------------

%overlap calculation method
soround=(smax-smin+1)*6; %preselection in multiples of samplesize                                                             %pre selection inteval
tsp=handles.psave;                                                                            %treshholding
%--------------------------------------


nwrites=0; % count wirtten data (to free ram)

%% upper triangle matrix of Overlaps
disp('calculating overlap Matrix between norefs')
hw = waitbar(0,'calculating overlap Matrix between norefs');

%Loop over all Samples sorted by mass
for i=1:l_data
 
    if ~mod(i,10000) || i==l_data
        waitbar(i/l_data,hw,[ 'finding friends of sample ' num2str(i) ' / ' num2str(l_data)])
    end   
    
        %Need to write data to file to gain memory ?
        if ~mod(i,ind_store_len) || i==l_data
            
                disp('write indices to file')
                fwrite(hI,I(1:i0b-1),'double');
                fwrite(hJ,J(1:i0b-1),'double');
                fwrite(hO,O(1:i0b-1),'double');
                
                %Reset
                I=zeros((l_data),1);%row index
                J=I;                %column index
                O=J;                %Overlap value
                i0b=1;
                nwrites=nwrites+1;

        end
   
    
    %preselection search interval
    soround=min(soround,l_data-i);
    
    %preselection
    pre=i+find(abs(data(i,mass)-data(i+1:i+soround,mass))<0.002 & data(i,sample)~=data(i+1:i+soround,sample) );
    
    if ~isempty(pre)
        
        %calculation of overlaps
        O_temp=pfun(data(i,intens),data(pre,intens)...
            ,data(i,mass),data(pre,mass)...
            ,1/sqrt(log(4))*data(i,mass)./data(i,res),1/sqrt(log(4))*data(pre,mass)./data(pre,res) );
        
        %treshholding
        O_temp=O_temp.* (O_temp>tsp);
        pre(O_temp==0)=[];
        O_temp(O_temp==0)=[];
        
        %delete all matches fail threshold
        if numel(pre)==0;continue;end
        
        
        
        %best match of each sample only: sort from high to low Overlap
        [~, i_sort]=sort(O_temp);
        i_sort=i_sort(end:-1:1);
        
        %take first and through sorting best match of each sample
        [~, i_unq, ~]=unique(data(pre(i_sort),sample),'first');
        O_temp=O_temp(i_sort(i_unq));
        
        %Everthing from now orderd by mass again not from high to low Overlap !
        % (in its order by growing mass)
        [pre i_sort]=sort(pre(i_sort(i_unq)));%bring pre selection back to order of growing mass still containing only best match of each sample
        O_temp=O_temp(i_sort);
        
        
        
        %identify gaps in row indices (indicator for cluster seperators)
        if  (i0 > 1 && (i - I_last) > 1)
  
            if gap_count > length(I_gaps);I_gaps(end+1000)=0;end
            gap_count=gap_count+1;
            I_gaps(gap_count)=i0-1;%i0
            
        end
        
        %adress-indices of vectors
        indicesb=i0b:i0b+length(pre)-1;%growth will be reshaped
        
        
        I(indicesb)=i;
        J(indicesb)=pre;     %assign friends of i
        O(indicesb)=O_temp;  %and their Overlaps
        
        %counting vector adress "pointer"
        i0=i0+length(pre); %theoretical Index in array with total length
        i0b=i0b+length(pre);%Index in substract of total arra actual in memory
        I_last=i;
    end
    
    %schreibennötoig
    
end

I_gaps=I_gaps(1:gap_count);



% %reduce Ovarly sparse to Information size
I=I(1:i0b-1);
J=J(1:i0b-1);
O=O(1:i0b-1);

fwrite(hI,I(1:i0b-1),'double')
fwrite(hJ,J(1:i0b-1),'double')
fwrite(hO,O(1:i0b-1),'double')
fclose(hI);
fclose(hJ);
fclose(hO);

I_len=i0-1;%length of Indice data (I,J,O)
clear J O i0b I rsc i_sort i_unq i0


hI=fopen('I.bin','rb');
hJ=fopen('J.bin','rb');
hO=fopen('O.bin','rb');


% %
% %----------------
%end
close(hw);

% disp('build sparse')


%ovlp=sparse(double(I),double(J),O,l_data,l_data,nnz(O));
%
%% build clusters
%identyfy clusters by gaps in rowindices of nonzero entries

disp('build clusters')
%h=find(diff(I)>1); %cluster speration tokens (gaps)

%initialize
%C=data(:,intens);       %Clusterdata - the Peaks
CI=zeros(l_data,1);     %row coordinates (determine Clusters)
CJ=CI;                  %column coordinates
Cn=CI;                  %# cluster members
mean_mass=CI;           %mean values (mass intensity(here max.) Resolution)
max_intens=CI;         %to form a Master
mean_res=CI;
index=1;                %currenr position of row of clusters/singletons
%----------------------------------------------
%first singles
fseek(hI,0,'bof');
I_part=fread(hI,1,'double');
l=length(1:I_part-1);
CJ(index:l)= data(1:I_part-1,sample);
CI(index:l)=index:l;
Cn(index:l)=1;
mean_mass(index:l)=data(1:I_part-1,mass);
max_intens(index:l)=data(1:I_part-1,intens);
mean_res(index:l)=data(1:I_part-1,res);
cr=length(1:I_part-1);
index=l;
%----------------

%first cluster
fseek(hI,0,'bof');
cr=cr+1;
pos0=1;%reading position in file start
pos1=I_gaps(1);     %reading position in file end
I_part=fread(hI,pos1-pos0+1,'double');
val=(cr:I_part(end)+1);%range until I(I_gaps)+1

%handle peaks of same sample -> seperate cluster
if length(data(val,sample))~=length(unique(data(val,sample)));
    ovlp_part=get_overlaps(I_part,val,hI,hJ,hO,pos0,pos1);
    
    sects=cluster_reorganize(data,val,ovlp_part);%get section points
    [CI,CJ,Cn,cr,index,mean_mass,max_intens,mean_res]=...
    build_sub_clusters(data,sects,val,CI,CJ,Cn,cr,index,mean_mass,max_intens,mean_res);

    
else
    
    %keep cluster unchanged
    l=length(val);
    CJ(index+(1:l))= data(val,sample);
    CI(index+(1:l))=cr;
    Cn(cr)=l;
    mean_mass(cr)=mean(data(val,mass));
    max_intens(cr)=max(data(val,intens));
    mean_res(cr)=mean(data(val,res));
    index=index+l;
    
end



for ci=2:length(I_gaps)%loop over initial clusters
 
    %if   ci  == 1658;keyboard;end
    if ~mod(ci,5000) || ci== length(I_gaps)
        sprintf('build and check intial cluster: %i/%i',ci,length(I_gaps))
    end
    
    %singles
    pos0=I_gaps(ci-1);%  end of previous cluster (without In=Jn)
    pos1=I_gaps(ci-1)+1;% until Begining od current cluster
    fseek(hI,(pos0-1)*8,'bof');%go to start of current cluster
    cluster1_end=fread(hI,1,'double')+1;%end of prev cluster (+1 Identity In = Jn not wirtten to file)
    fseek(hI,(pos1-1)*8,'bof');%double
    cluster2_start=fread(hI,1,'double');
    
    % Are there singles between current and last cluster
    if cluster2_start-1 - cluster1_end+1 > 1
    val=cluster1_end+1:cluster2_start-1;
    l=length(val);
    CJ(index+(1:l))= data(val,sample);
    CI(index+(1:l))=cr+(1:l);
    Cn(cr+(1:l))=1;
    mean_mass(cr+(1:l))=data(val,mass);
    max_intens(cr+(1:l))=data(val,intens);
    mean_res(cr+(1:l))=data(val,res);
    index=index+l;
    cr=cr+l;
    end
    
    %CLUSTER ##########################################################
    cr=cr+1;
    pos0=I_gaps(ci-1)+1;%  end of previous cluster (without In=Jn)
    pos1=I_gaps(ci);% until Begining of current cluster
    fseek(hI,(pos0-1)*8,'bof');%double
    I_part=fread(hI,(pos1)-(pos0)+1,'double');
    %cluster2_start=I_part(1);
    cluster2_end=I_part(end)+1; 
    %keine lücke im dreieck in der letzten zeile am ende
    val=cluster2_start:cluster2_end;
    
       
        %handle peaks of same sample -> seperate cluster
        if length(data(val,sample))~=length(unique(data(val,sample)));
            
            ovlp_part=get_overlaps(I_part,val,hI,hJ,hO,pos0,pos1);

            sects=cluster_reorganize(data,val,ovlp_part);%get section points
            if length(sects)~=length(unique(sects)) || ~issorted(sects);keyboard;end
            
    [CI,CJ,Cn,cr,index,mean_mass,max_intens,mean_res]=...
    build_sub_clusters(data,sects,val,CI,CJ,Cn,cr,index,mean_mass,max_intens,mean_res);

        else %keep cluster uncahnged
            
            l=length(val);
            CJ(index+(1:l))= data(val,sample);
            CI(index+(1:l))=cr;
            Cn(cr)=l;
            mean_mass(cr)=mean(data(val,mass));
            max_intens(cr)=max(data(val,intens));
            mean_res(cr)=mean(data(val,res));
            index=index+l;
       end
        %##################################################################
end        
    

%pre last singeltons
    pos0=I_gaps(ci);%  end of previous cluster (without In=Jn)
    pos1=I_gaps(ci)+1;% until Begining od current cluster
    fseek(hI,(pos0-1)*8,'bof');%double
    cluster1_end=fread(hI,1,'double')+1;
    fseek(hI,(pos1-1)*8,'bof');%double
    cluster2_start=fread(hI,1,'double');
    
    % Are ther singles between current an last cluster
    if cluster2_start-1 - cluster1_end+1 > 1
    val=cluster1_end+1:cluster2_start-1;
    l=length(val);
    CJ(index+(1:l))= data(val,sample);
    CI(index+(1:l))=cr+(1:l);
    Cn(cr+(1:l))=1;
    mean_mass(cr+(1:l))=data(val,mass);
    max_intens(cr+(1:l))=data(val,intens);
    mean_res(cr+(1:l))=data(val,res);
    index=index+l;
    cr=cr+l;
    end


    %Last CLUSTER ##########################################################
    cr=cr+1;
    pos0=I_gaps(ci)+1;%  end of previous cluster (without In=Jn)
    pos1=I_len;% until Begining od current cluster
    fseek(hI,(pos0-1)*8,'bof');%double
    I_part=fread(hI,(pos1)-(pos0)+1,'double');
    cluster2_start=I_part(1);%fread(hI,1,'int32')+1;
    cluster2_end=I_part(end)+1; %fseek(hI,(pos1-1)*8,'bof');%Int32
    val=cluster2_start:cluster2_end;
    

%handle peaks of same sample -> seperate cluster
if length(data(val,sample))~=length(unique(data(val,sample)));
    
    %ovlp_part=ovlp(val,val);
    ovlp_part=get_overlaps(I_part,val,hI,hJ,hO,pos0,pos1);
    
    sects=cluster_reorganize(data,val,ovlp_part);%get section points
    
    [CI,CJ,Cn,cr,index,mean_mass,max_intens,mean_res]=...
    build_sub_clusters(data,sects,val,CI,CJ,Cn,cr,index,mean_mass,max_intens,mean_res);

else  %keep cluster uncahnged
    
    l=length(val);
    CJ(index+(1:l))= data(val,sample);
    CI(index+(1:l))=cr;
    Cn(cr)=l;
    mean_mass(cr)=mean(data(val,mass));
    max_intens(cr)=max(data(val,intens));
    mean_res(cr)=mean(data(val,res));
    index=index+l;
end

%last singeltons
val=cluster2_end+1:size(data,1);
l=length(val);
CJ(index+(1:l))= data(val,sample);
CI(index+(1:l))=cr+(1:l);
Cn(cr+(1:l))=1;
mean_mass(cr+(1:l))=data(val,mass);
max_intens(cr+(1:l))=data(val,intens);
mean_res(cr+(1:l))=data(val,res);
cr=cr+l;

CI(CI==0)=[];
CJ(CJ==0)=[];
Cn(Cn==0)=[];
mean_mass(mean_mass==0)=[];
mean_res(mean_res==0)=[];
max_intens(max_intens==0)=[];

storespar=sparse(CI,CJ,data(:,intens),cr,smax-smin+1,l_data);%cluster matrix which rows will be written inbetween existent rows in assigned file


fclose(hI);
fclose(hJ);
fclose(hO);



%write clusters t file

cols=col1+2*(col1==4)+(smin:smax)-3;

[~,header]=xlsread([handles.assigned_dir '\master_add_assigned.xlsx'],1,'1:1');

dateinameout='clusters.xlsx';
l=length(header);
[status,msg]=xlswrite([handles.assigned_dir '\' dateinameout],header,1,...
                ['A' num2str(1) ':' col2excellchar(l) num2str(1)]);


mem=memory;
felder=floor(mem.MaxPossibleArrayBytes/8/5); %double 8 bytes
nrows=floor(felder/length(header));
escript=cell(nrows,length(header));
nwrites=ceil(length(Cn)/nrows);

for write=1:nwrites

   i1=1+nrows*(write-1);
   i2=i1+nrows-1;
   if write==nwrites
      i2=length(Cn); 
   end
   
    
output=full(storespar(i1:i2,:));
output(output==0)=nan;
loc=length(Cn);
escript(1:loc,[1 3 4 5 6 cols])=num2cell([mean_mass(i1:i2) max_intens(i1:i2) mean_res(i1:i2) mean_mass(i1:i2) Cn(i1:i2) output]);        
escript(1:loc,2)={'no reference'};

[status,msg]=xlswrite([handles.assigned_dir '\' dateinameout],escript(1:loc,:),1,...
                ['A' num2str(i1+1) ':' col2excellchar(l) num2str(i2+1)]);
%%
end




%% einfügen in master datei
delete('norefs.dat','*.bin');