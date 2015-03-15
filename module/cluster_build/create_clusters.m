function [storespar cr Cn mean_mass mean_res mean_intens]=create_clusters(data,smin,smax)

%indexing
mass=1;
intens=2;
res=3;
sample=4;
%--------
%% build clusters
%identyfy clusters by gaps in rowindices of nonzero entries
hI=fopen('I.bin','rb');
hJ=fopen('J.bin','rb');
hO=fopen('O.bin','rb');

disp('build clusters')


%initialize
CI=zeros(l_data,1);     %row coordinates (determine Clusters)
CJ=CI;                  %column coordinates
Cn=CI;                  %# cluster members
mean_mass=CI;           %mean values (mass intensity Resolution)
mean_intens=CI;         %to form a Master
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
mean_intens(index:l)=data(1:I_part-1,intens);
mean_res(index:l)=data(1:I_part-1,res);
cr=length(1:I_part-1);
index=l;
%----------------

%first cluster
cr=cr+1;
pos0=I_gaps(1);%reading position in file start
pos1=pos0;     %reading position in file end
fseek(hI,(I_gaps(1)-1)*8,'bof');%double
I_part=fread(hI,1,'double');
val=(cr:I_part+1);%range until I(I_gaps)+1

%handle peaks of same sample -> seperate cluster
if length(data(val,sample))~=length(unique(data(val,sample)));
    ovlp_part=get_overlaps(I_part,val,hI,hJ,hO,pos0,pos1);
    
    sects=cluster_reorganize(data,val,ovlp_part);%get section points
    [CI,CJ,Cn,cr,index,mean_mass,mean_intens,mean_res]=...
    build_sub_clusters(data,sects,val,CI,CJ,Cn,cr,index,mean_mass,mean_intens,mean_res);

    
else
    
    %keep cluster unchanged
    l=length(val);
    CJ(index+(1:l))= data(val,sample);
    CI(index+(1:l))=cr;
    Cn(cr)=l;
    mean_mass(cr)=mean(data(val,mass));
    mean_intens(cr)=mean(data(val,intens));
    mean_res(cr)=mean(data(val,res));
    index=index+l;
    
end



for ci=2:length(I_gaps)%loop over initial clusters
      if   ci  == 1658;keyboard;end
    if ~mod(ci,5000) || ci== length(I_gaps)
        sprintf('build and check intial cluster: %i/%i',ci,length(I_gaps))
    end
    
    %singles
    pos0=I_gaps(ci-1);%  end of previous cluster (without In=Jn)
    pos1=I_gaps(ci-1)+1;% until Begining od current cluster
    fseek(hI,(pos0-1)*8,'bof');%double
    cluster1_end=fread(hI,1,'double')+1;
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
    mean_intens(cr+(1:l))=data(val,intens);
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
            
    [CI,CJ,Cn,cr,index,mean_mass,mean_intens,mean_res]=...
    build_sub_clusters(data,sects,val,CI,CJ,Cn,cr,index,mean_mass,mean_intens,mean_res);

        else %keep cluster uncahnged
            
            l=length(val);
            CJ(index+(1:l))= data(val,sample);
            CI(index+(1:l))=cr;
            Cn(cr)=l;
            mean_mass(cr)=mean(data(val,mass));
            mean_intens(cr)=mean(data(val,intens));
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
    mean_intens(cr+(1:l))=data(val,intens);
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
    
    [CI,CJ,Cn,cr,index,mean_mass,mean_intens,mean_res]=...
    build_sub_clusters(data,sects,val,CI,CJ,Cn,cr,index,mean_mass,mean_intens,mean_res);

else  %keep cluster uncahnged
    
    l=length(val);
    CJ(index+(1:l))= data(val,sample);
    CI(index+(1:l))=cr;
    Cn(cr)=l;
    mean_mass(cr)=mean(data(val,mass));
    mean_intens(cr)=mean(data(val,intens));
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
mean_intens(cr+(1:l))=data(val,intens);
mean_res(cr+(1:l))=data(val,res);
cr=cr+l;

CI(CI==0)=[];
CJ(CJ==0)=[];
mean_mass(mean_mass==0)=[];
mean_res(mean_res==0)=[];
mean_intens(mean_intens==0)=[];

storespar=sparse(CI,CJ,data(:,intens),cr,smax-smin+1,l_data);

fclose(hI);
fclose(hJ);
fclose(hO);