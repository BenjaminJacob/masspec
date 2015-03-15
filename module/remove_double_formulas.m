function remove_double_formulas

[filename,filepath,filter]=uigetfile('*.xlsx');
filename=[filepath filename];

xls=actxserver('Excel.Application');%start excel server
wb = xls.Workbook.Open(filename);  %open file
wb.Sheets.Item(1).Activate;      %activate sheet 1
as=wb.ActiveSheet;               %remember active sheet

rowEnd = as.Range('A1').End('xlDown').Row;

col=2;




for row=2:rowEnd
    
    if ~mod(row,5000) || row==rowEnd;sprintf('row %i / %i',row,rowEnd);end
    
    formula=as.Range([col2excelchar(col) num2str(row)]).Value;
    i_slash=find(formula=='/');
    
    
    if i_slash
        
        parts{1}=formula(1:i_slash-1);
        
        for i=2:length(i_slash)
            parts{i}=formula(i_slash(i-1)+1:i_slash(i)-1);
        end
        parts{end+1}=formula(i_slash(end)+1:end);
        parts=parts(end:-1:1);
        l_parts=length(parts);
        
        for i=1:length(i_slash)
            
            if i==1
                del_pos1=i_slash(end);
            else
                del_pos1=i_slash(end-i+1);
            end
            
            
            part = formula(del_pos1+1:end);
            part(part==' ')=[];
            
            
            if sum(strcmp({part},parts)) >1
                formula(del_pos1:end)=[];
                parts(end-l_parts+i)=[];
            end
            
        end
        
        
        as.Range([col2excelchar(col) num2str(row)]).Value=formula;
        
    end
end

%save changes
wb.Save;
%close open excel interaction
wb.Close;
delete(xls);
end


function colchar=col2excelchar(col)

if col<=26 %1 Buschstabe in excel
    colchar=char(col+64);
    
elseif col<=702 %2Buchstaben in excel
    n=floor(col/26);
    m=mod(col,26);
    r=col-(n-(m==0))*26;
    char2=char(64+r);
    char1=char(n+65-1-(m==0));
    colchar=[char1 char2];%regionende unten rechts
    
else   %3 Buchstaben in excel
    
    n1=floor((col-26-1)./(26*26));% stelle 1 und 2 durhclaufen +ZZ
    u2626=col-26-1-n1*26*26;
    n2=mod(floor(u2626/26),26);
    n3=mod(u2626,26);
    char1=char(64+n1);
    char2=char(65+n2);
    char3=char(65+n3);
    colchar=[char1 char2 char3];%regionende unten rechts
    
end

end