cm=sortrows(load('color_marks.dat'),1);
l=length(cm);

filename=[cd '\master_add_assigned2.xlsx'];
[nrows ncols]=getExcelDim(filename);

masses_master=xlsread(filename,['A2:A' num2str(nrows)]);

rows=zeros(l,1);
for i=1:l    
    rows(i)=find(masses_master==cm(i))+1;
end
    Excel_set_color(filename,rows,cm(:,2));