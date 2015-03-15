
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

row1=2;
row2=2;
row3=2;

mass1=as.Range([col2excelchar(1) num2str(row1)]).Value;
mass2=as2.Range([col2excelchar(1) num2str(row2)]).Value;

col1='A';
coln=col2excelchar(ncols);

tic
for k=1:3000%while ~isnan(mass1) || ~isnan(mass1)

    
    if mass1 <= mass2

        aso.Range([col2excelchar(1) num2str(row3)]).Value=mass1;
        
        for col=2:ncols
        
            
            Range = get(as, 'Range', 'A1:B2');
            B = Range.value;
            
            rowchar=num2str(row1);
            Range = get(as, 'Range', [col1 rowchar '' col1 rowchar ]);
            B = Range.value;
            
            
            aso.Range([col2excelchar(col) num2str(row3)]).Value=...
            as.Range([col2excelchar(col) num2str(row1)]).Value;    
        
        end
        
        row1=row1+1;
        mass1=as.Range([col2excelchar(1) num2str(row1)]).Value;


    else
        
        
        aso.Range([col2excelchar(1) num2str(row3)]).Value=mass2;
        
        for col=2:ncols
        
            aso.Range([col2excelchar(col) num2str(row3)]).Value=...
            as2.Range([col2excelchar(col) num2str(row2)]).Value;    
        
        end
        
        row2=row2+1;
        mass2=as2.Range([col2excelchar(1) num2str(row2)]).Value;
    end

    
    
    row3=row3+1;
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

