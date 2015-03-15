
profile on


%% Open workbooks and files
filename='C:\Users\user\Desktop\Benjamin masspec stand alone\test\bearbeitet\master_add_assigned.xlsx'
filename2='C:\Users\user\Desktop\Benjamin masspec stand alone\test\bearbeitet\clusters.xlsx'
filename3='C:\Users\user\Desktop\Benjamin masspec stand alone\test\bearbeitet\ass2.xlsx'


%mainfile
xls=actxserver('Excel.Application');%start excel server
wb = xls.Workbook.Open(filename);  %open file
wb.Sheets.Item(1).Activate;      %activate sheet 1
as=wb.ActiveSheet;               %remember active sheet


%clusterfile
%xls2=actxserver('Excel.Application');%start excel server
wb2 = xls.Workbook.Open(filename2);  %open file
wb2.Sheets.Item(1).Activate;      %activate sheet 1
as2=wb2.ActiveSheet;               %remember active shee



%outputfile
%xlso=actxserver('Excel.Application');%start excel server
wbo = xls.workbooks.Add;
xlFormat=51; %xlsx                %save workbook to file
wbo.SaveAs(filename3, xlFormat);  %save workbook to file
wbo.Sheets.Item(1).Activate;      %activate sheet
aso=wbo.ActiveSheet;               %remember active shee

%%

%transfere header
row=1;
col=1;
val=1;
while ~isnan(val)
    
    val=as.Range([col2excelchar(col) num2str(row)]).Value;
    
    if ~isnan(val)
        
        aso.Range([col2excelchar(col) num2str(row)]).Value=val;
        col=col+1;
    end
    
end
ncols=col;


%col_letters

%%

row1=2; row11=2;
row2=2; row21=2;
row3=2; row31=2;

mass1=as.Range([col2excelchar(1) num2str(row1)]).Value;
mass2=as2.Range([col2excelchar(1) num2str(row2)]).Value;

col1='A';
coln=col2excelchar(ncols);

tic
while ~isinf(mass1) || ~isinf(mass2) %empty cells=> nan => inf
    
    
    if mass1 <= mass2 %take row from reference
        
        while mass1 <= mass2
           
            
            row11 = row11 + 1;
            row31 = row31 + 1;
            mass1=as.Range([col2excelchar(1) num2str(row11)]).Value;
            
        end
         
        row11=row11-1;
        row31=row31-1;
        
        Range = get(as, 'Range', [col1 num2str(row1) ':' coln num2str(row11) ]);
        B = Range.value;
        
        Range3 = get(aso,'Range',[col1 num2str(row3) ':' coln num2str(row31) ]);
        set(Range3, 'Value', B);
        
        row1=row11+1;row11=row1;
        row3=row31+1;row31=row3;
        
      
        
        
    else
        
        while mass2 <= mass1
           
            
            row21 = row21 + 1;
            row31 = row31 + 1;
            mass2=as2.Range([col2excelchar(1) num2str(row21)]).Value;
            
        end
         
        row21=row21-1;
        row31=row31-1;
        
        Range = get(as2, 'Range', [col1 num2str(row2) ':' coln num2str(row21) ]);
        B = Range.value;
        
        Range3 = get(aso,'Range',[col1 num2str(row3) ':' coln num2str(row31) ]);
        set(Range3, 'Value', B);
        
        row2=row21+1;row21=row2;
        row3=row31+1;row31=row3;
        
        
    end
    
    if isnan(mass1)  % continue file 2 to end if end of 1 mass2 always < inf
           mass1=inf; 
    end
        
    if isnan(mass2) % continue file 2 to end if end of 1 mass1 allways < inf
         mass2=inf; 
    end
    
    
end


%% sva changes and close
wb.Close;
%delete(xls);

wb2.Close;
%delete(xls2);

wbo.Save;
wbo.Close;
delete(xls);
t1=toc

profile viewer

