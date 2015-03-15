
function [data_temp textdata_temp]=asciiread(name)
%wie viele/welche einträge
h=fopen(name);
zeile=fgetl(h);
ncols=sum(zeile==(9))+1; %Wieviel tabstops (asciicode 9) ? -> tabstops +1 = spalten
fclose(h)

%id mass intens res sn
h=fopen(name);
form(1:2)=[char(37) 's'];
form(3:3:ncols*3-1)=' ';
form(4:3:ncols*3-1)='%';
form(5:3:ncols*3-1)='s';
scan=textscan(h,form);
fclose(h)

data_temp=zeros(size(scan{1},1)-1,3);
textdata_temp=cell(length(scan{1}),1);
textdata_temp(:)={name(find(name=='\',1,'last')+1:find(name=='.',1,'last')-1)};
for i=1:length(scan)
    if  ~isempty(regexp(scan{i}{1}, 'mass','ignorecase'))    %m(ass)

        for j=2:length(scan{1})
            data_temp(j-1,1)=str2num(scan{i}{j});
        end
    elseif ~isempty(regexp(scan{i}{1}, 'Intens','ignorecase'))%Intensity
        
        for j=2:length(scan{1})
            data_temp(j-1,2)=str2num(scan{i}{j});
        end
         
    elseif ~isempty(regexp(scan{i}{1}, 'resolution','ignorecase'))%Resolution
        
        for j=2:length(scan{1})
            data_temp(j-1,3)=str2num(scan{i}{j});
        end
    end
end