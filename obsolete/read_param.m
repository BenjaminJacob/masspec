
fid=fopen('parameter.in');
patterns={'sample_dir','assigned_dir','masterlist','tol',...
    'psave','pcrit','nsamples','overlap'};
att={'str','str','str','num','num','num','num','num'};

indices=1:length(patterns);



line=fgetl(fid);

while ischar(line(1))
    for i=indices
        
        pattern=[patterns{i} '='];
        
        percpos=find(line=='%');
        if percpos
            line=line(1:percpos-1);
        end
        if strfind(line,pattern)
            
            if strcmp(att{i},'str')
            val=line(strfind(line,pattern)+length(pattern):end);
            else
            
                val=str2double(line(or(line>='0' & line <= '9', line=='.' )));

            end
            assignin('base','temp',val)
            eval(['handles.' pattern  'temp'])
            
            
            indices(indices==i)=[];
            
        end
        
    end
    
line=fgetl(fid);
end


fclose all