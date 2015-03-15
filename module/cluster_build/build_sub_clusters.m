function [CI,CJ,Cn,cr,index,mean_mass,max_intens,mean_res]=...
    build_sub_clusters(data,sects,val,CI,CJ,Cn,cr,index,mean_mass,max_intens,mean_res)
%indexing
mass=1;
intens=2;
res=3;
sample=4;

start=1;
    for j=1:length(sects)
        
        val_c=val(start:sects(j)-1);
        l=length(val_c);
        CJ(index+(1:l))= data(val_c,sample);
        CI(index+(1:l))=cr;
        Cn(cr)=l;
        mean_mass(cr)=mean(data(val_c,mass));
        max_intens(cr)=max(data(val_c,intens));
        mean_res(cr)=mean(data(val_c,res));
        index=index+l;
        cr=cr+1;
        start=sects(j);
    end
    
    %last sect to end
    val_c=val(sects(j):end);
    l=length(val_c);
    CJ(index+(1:l))= data(val_c,sample);
    CI(index+(1:l))=cr;
    Cn(cr)=l;
    mean_mass(cr)=mean(data(val_c,mass));
    max_intens(cr)=max(data(val_c,intens));
    mean_res(cr)=mean(data(val_c,res));
    index=index+l;